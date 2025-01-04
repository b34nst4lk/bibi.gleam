import gleam/bool
import gleam/int
import gleam/list

import bibi/coords.{type Coords}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

pub type BitboardError {
  BitboardError(message: String)
}

pub fn from_coords(width: Int, height: Int, coords: Coords) -> Result(Bitboard, String) {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  use <- bool.guard(coords.x < 0, Error("Coords.x must be positive"))
  use <- bool.guard(coords.y < 0, Error("Coords.y must be positive"))
  use <- bool.guard(
    coords.x >= width,
    Error("Coords.x must be less than width"),
  )
  use <- bool.guard(
    coords.y >= height,
    Error("Coords.y must be less than height"),
  )

  let val = int.bitwise_shift_left(1, width * coords.y + coords.x)
  Ok(Bitboard(width, height, val))
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
