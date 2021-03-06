open Nm_ast
open BatList

let nidl = ref [];;
let inst_list = ref [];;
let mem_list = ref [];;

let make_undef_var_dec id = 
  Shared.Types.{var_id = id; type_id = "undefined"}

let make_mem id vl =
  let var_dec = make_undef_var_dec id in
  {var_dec; value = vl}

let add_to_mem eq =
  let first = List.hd eq.lhs in
  match eq.rhs with
    | Fby(pre, next) -> mem_list := make_mem first pre ::!mem_list
    | _ -> ()

let explore_mem_list eql =
  List.iter add_to_mem eql

let make_undef_mach_dec id =
  Sol.Ast.{mach_id = id; type_id = id}

let add_to_inst eq =
  match eq.rhs with
    | NodeCall(id, _) -> inst_list := (make_undef_mach_dec id)::!inst_list
    | _ -> ()

let explore_inst_list eql =
  List.iter add_to_inst eql

let get_id_list eql =
  List.fold_left (fun acc eq -> acc@eq.lhs) [] eql

let get_interface_type = function
  | [] -> raise (Failure "Interface node has no type to build interface on.")
  | vd::[] -> Some Shared.Types.(vd.type_id)
  | _::_ -> raise (Failure "Interface node must have only one parameter to build interface on.")

let list_node_ids ndl =
  List.iter (fun node -> nidl := node.id::(!nidl)) ndl

let mem_id id mem_list =
  let idl = List.map (fun mem -> mem.var_dec.var_id) mem_list in
  mem id idl

let get_undeclared_id_list dec_idl idl =
  let tmp = List.filter (fun id -> not (mem id dec_idl) && not (mem_id id !mem_list)) idl in
    unique tmp

let change_mem id =
  match mem_id id !mem_list with
    | true -> "state(" ^ id ^ ")"
    | false -> id

let id_of_vardec vd =
  Shared.Types.(vd.var_id)

let make_step avd rvd vd instl =
  Sol.Ast.{ avd; rvd; vd; instl}

let rec make_reset () =
  let inst_res = List.map (fun inst -> Sol.Ast.(Reset(inst.mach_id))) !inst_list in
  let mem_reset = List.map
    (fun mem -> Sol.Ast.StateAssign(mem.var_dec.var_id, sol_of_val mem.value)) !mem_list in
    inst_res@mem_reset

and sol_of_ast ast =
  let tdl = ast.type_dec_list in
  let ndl = ast.node_list in
  let _ = list_node_ids ndl in
  let mdl = sol_of_node_list ndl in
  Sol.Ast.{tdl = tdl; mdl = mdl;}

and sol_of_cexp var_id cexp =
  match cexp with
    | Merge(id, fll) -> Sol.Ast.Case(id, sol_of_flow_list var_id fll)
    | Exp(exp) -> Sol.Ast.VarAssign([var_id], sol_of_exp exp)

and sol_of_eq_list eql =
  List.map sol_of_eq eql

and sol_of_eq eq =
  let first = List.hd eq.lhs in
  match eq.rhs with
  (* This is kinda hackish *)
    | CExp(cexp) -> sol_of_cexp first cexp
    | Fby(pre, next) -> Sol.Ast.StateAssign(first, sol_of_exp next)
    | NodeCall(id, expl) -> Sol.Ast.VarAssign(eq.lhs, Sol.Ast.Step(id, sol_of_exp_list expl))

and sol_of_exp_list expl =
  List.map sol_of_exp expl

and sol_of_exp exp =
  match exp with
    | Op(id, expl) when mem id !nidl -> raise (Failure ("Shouldn't use node call as op:" ^ id))
    | Op(id, expl) -> Sol.Ast.Op(id, List.map sol_of_exp expl)
    | Value(vl) -> sol_of_val vl
    | Variable(id) when mem_id id !mem_list -> Sol.Ast.State(id)
    | Variable(id) -> Sol.Ast.Variable(id)
    | When(exp) -> sol_of_exp exp

and sol_of_flow_list var_id fll =
  List.map (sol_of_flow var_id) fll

and sol_of_flow var_id flow =
  Sol.Ast.Branch(flow.constr, [sol_of_cexp var_id flow.cexp])

and sol_of_node_list ndl =
  List.map sol_of_node ndl

and sol_of_node node =
  let _ = inst_list := [] in
  let _ = mem_list := [] in
  let _ = explore_mem_list node.eql in
  let _ = explore_inst_list node.eql in
  let interface = if node.interface then get_interface_type node.in_vdl else None in
  let id = node.id in
  let dec_idl = List.map id_of_vardec node.in_vdl in
  let undec_idl = get_undeclared_id_list dec_idl (get_id_list node.eql) in
  let step_var_decs = List.map make_undef_var_dec undec_idl in
  let step = make_step node.in_vdl node.out_vdl step_var_decs (sol_of_eq_list node.eql) in
  let reset = make_reset () in
  let memories = List.map (fun mem -> mem.var_dec) !mem_list in
  Sol.Ast.{id; memory = memories; instances = !inst_list; interface; reset = reset; step}

and sol_of_val = function
    | Litteral(lit) -> Sol.Ast.Value(Sol.Ast.Litteral(lit))
    | Constr(constr) -> Sol.Ast.Value(Sol.Ast.Constr(constr.id))