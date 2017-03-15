open Types
open Printf
let concat = String.concat;;

let spaces count =
    Bytes.to_string (Bytes.make count ' ')

let iendl, incendl, decendl, incindent, decindent =
    let count = ref 0 in
    (fun () -> "\n" ^ spaces !count),
    (fun () -> count := !count + 2; "\n" ^ spaces !count),
    (fun () -> count := !count - 2; "\n" ^ spaces !count),
    (fun () -> count := !count + 2),
    (fun () -> count := !count -2);;

let rec string_of_machine = function
    | {id; memory; instances; reset; step} ->
            "machine " ^ id ^ " =" ^ iendl ()
            ^ string_of_memory memory ^ iendl ()
            ^ string_of_instances instances ^ decendl ()
            ^ string_of_reset reset ^ decendl ()
            ^ string_of_step_dec step

and string_of_memory mem =
    "memory " ^ (string_of_vardecs mem)

and string_of_instances inst =
    "instances " ^ (List.map string_of_machdec inst |> concat ", ")

and string_of_reset reset_exp =
    "reset () = " ^ incendl() ^ string_of_seqexp reset_exp

and string_of_step_dec = function
    | {avd; rvd; vd; sexp} ->
            "step(" ^ (string_of_vardecs avd) ^ ") returns ("
            ^ (string_of_vardecs rvd) ^ ") = " ^ iendl()
            ^ "var " ^ (string_of_vardecs vd) ^ " in " ^ iendl()
            ^ string_of_seqexp sexp ^ (incindent(); incindent(); "\n")

and string_of_vardecs vds =
    List.map string_of_vardec vds |> concat ", "

and string_of_seqexp exps =
    List.map string_of_exp exps |> concat (";" ^ iendl())

and string_of_exp = function
    | VarAssign(id, vl) -> id ^ " = " ^ string_of_val vl
    | StateAssign(id, vl) -> "state(" ^ id ^ ") = " ^ string_of_val vl
    | Skip -> "skip"
    | Reset(id) -> id ^ ".reset()"
    | Step(idl, id, vll) -> string_of_tuple idl ^ " = "
        ^ id ^ ".step(" ^ (List.map string_of_val vll |> concat ", ") ^ ")"
    | Case(id, bl) ->
            let a = "case (" ^ id ^ ") {" ^ incendl() in
            let b = List.map string_of_branch bl |> concat (";" ^ iendl()) in
            let c = decendl() in
            let d = "}" in
            a ^ b ^ c ^ d

and string_of_branch = function
    | Branch(id, exp) -> id ^ ": " ^ string_of_seqexp exp

and string_of_val = function
    | Variable(id) -> id
    | State(id) -> "state(" ^ id ^ ")"
    | Immediate(i) -> string_of_int i

and string_of_tuple = function
    | x::[] -> x
    | xs -> wrap (xs |> concat ", ")

and string_of_vardec = function
    | VarDec(id, ty) -> id ^ " : " ^ ty

and string_of_machdec = function
    | MachDec(id, mid) -> id ^ " : " ^ mid

and string_of_machine_list ml =
    List.map string_of_machine ml |> concat (iendl())

and string_of_type_dec_list tdl =
    List.map string_of_type_dec tdl |> concat (iendl())

and string_of_ast = function
    | {tdl; mdl;} ->
            let a = string_of_type_dec_list tdl ^ iendl() in
            let b = string_of_machine_list mdl in
            a ^ b

and string_of_type_dec = function
    | TypeDec(id, cl) ->
            let a = "type " ^ id ^ " = " in
            let b = cl |> concat " | " in
            a ^ b