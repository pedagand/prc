type event = Collide | Move | ArrowUp | ArrowDown
type atm = MoveUp | MoveDown

machine point =
  interface event
  memory x : int, y : int, st: atm, speed : int
  instances up : up, down : down
  reset () =
    state(x) = 200;
    state(y) = 200;
    state(speed) = 1;
    state(st) = MoveUp
  step(e : event) returns (x: int, y : int) =
    var x : int, y : int, st : atm, speed : int in
    x = state(x);
    st = state(st);
    case (st) {
      MoveUp : (st, y, speed) = up.step(e, state(y), state(speed)) |
      MoveDown : (st, y, speed) = down.step(e, state(y), state(speed))
    };
    state(st) = st;
    state(y) = y;
    state(speed) = speed

machine up =
  memory
  instances
  reset () = skip
  step(e : event, y : int, speed : int) returns (st: atm, y : int, speed: int) =
    var st : atm in
    st = MoveUp;
    case (e) {
      Move: y = subu(y, speed) |
      Collide: st = MoveDown |
      ArrowUp: speed = addu(speed, 1) |
      ArrowDown: speed = subu(speed, 1)
    }

machine down =
  memory
  instances
  reset () = skip
  step(e : event, y : int, speed : int) returns (st: atm, y: int, speed: int) =
    var st : atm in
    st = MoveDown;
    case (e) {
      Move: y = addu(y, speed) |
      Collide: st = MoveUp |
      ArrowUp: speed = subu(speed, 1) |
      ArrowDown: speed = addu(speed, 1)
    }
