import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Coords {
  Coords(x: Int, y: Int)
}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

pub type BitboardError {
  BitboardError(message: String)
}

fn validate(errors, message, result: Bool) {
  case !result {
    True -> list.append(errors, [message])
    False -> errors
  }
}

pub fn from_coords(
  width,
  height,
  coords: Coords,
) -> Result(Bitboard, BitboardError) {
  let dim_errors =
    []
    |> validate("width must be positive", width >= 0)
    |> validate("height must be positive", height >= 0)

  let coord_errors =
    []
    |> validate("x coords must be positive", coords.x >= 0)
    |> validate("y coords must be postive", coords.y >= 0)
    |> validate("x coords must be less than width", coords.x <= width)
    |> validate("y coords must be less than height", coords.y <= height)

  case dim_errors {
    [] -> {
      case coord_errors {
        [] -> {
          let val = int.bitwise_shift_left(1, width * coords.y + coords.x)
          Ok(Bitboard(width, height, val))
        }
        _ -> {
          Error(BitboardError(string.join(coord_errors, "\n")))
        }
      }
    }
    _ -> {
      Error(BitboardError(string.join(dim_errors, "\n")))
    }
  }
}

fn first_row(bitboard: Bitboard) -> Bitboard {
  let row =
    list.range(1, bitboard.width - 1)
    |> list.fold(1, fn(acc, _) {
      int.bitwise_or(int.bitwise_shift_left(acc, 1), 1)
    })
  Bitboard(..bitboard, val: row)
}

pub fn row(bitboard: Bitboard, row_no: Int) -> Bitboard {
  let first_row = first_row(bitboard)
  let row = int.bitwise_shift_left(first_row.val, row_no * bitboard.width)
  Bitboard(..bitboard, val: row)
}

fn first_col(bitboard: Bitboard) -> Bitboard {
  let col =
    list.range(0, bitboard.height - 2)
    |> list.fold(1, fn(acc, _) {
      int.bitwise_or(int.bitwise_shift_left(acc, bitboard.width), 1)
    })
  Bitboard(..bitboard, val: col)
}

pub fn col(bitboard: Bitboard, col_no: Int) -> Bitboard {
  let first_col = first_col(bitboard)
  let row = int.bitwise_shift_left(first_col.val, col_no)
  Bitboard(..bitboard, val: row)
}
