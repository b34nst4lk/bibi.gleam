//// The bibi/bitboard module provides the ability to create and manipulate bitboards

import gleam/bool
import gleam/int
import gleam/list
import gleam/string

import bibi/coords.{type Coords}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

// Validators
fn validate_equal_dimensions(
  bitboard_1: Bitboard,
  bitboard_2: Bitboard,
) -> Result(Nil, String) {
  use <- bool.guard(
    bitboard_1.width != bitboard_2.width,
    Error("bitboard widths must be equal"),
  )
  use <- bool.guard(
    bitboard_1.height != bitboard_2.height,
    Error("bitboard heights must be equal"),
  )
  Ok(Nil)
}

fn validate_coords_list(
  coords_list: List(Coords),
  width: Int,
  height: Int,
) -> Result(Nil, String) {
  case coords_list {
    [first, ..remaining] -> {
      let result = validate_coords(first, width, height)
      case result {
        Ok(_) -> validate_coords_list(remaining, width, height)
        _ -> result
      }
    }
    _ -> Ok(Nil)
  }
}

fn validate_coords(
  coords: Coords,
  width: Int,
  height: Int,
) -> Result(Nil, String) {
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

  Ok(Nil)
}

// Constructors

pub fn from_base2(
  width: Int,
  height: Int,
  bits: String,
) -> Result(Bitboard, String) {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))

  let assert Ok(val) = int.base_parse(bits, 2)
  use <- bool.guard(
    val >= int.bitwise_shift_left(1, width * height),
    Error("bits must be less than 1 << width * height"),
  )
  Ok(Bitboard(width, height, val))
}

pub fn from_coords(
  width: Int,
  height: Int,
  coords: Coords,
) -> Result(Bitboard, String) {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  let result = validate_coords(coords, width, height)
  case result {
    Ok(_) -> {
      let val = int.bitwise_shift_left(1, width * coords.y + coords.x)
      Ok(Bitboard(width, height, val))
    }
    Error(message) -> Error(message)
  }
}

pub fn from_list_of_coords(
  width: Int,
  height: Int,
  coords_list: List(Coords),
) -> Result(Bitboard, String) {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  let result = validate_coords_list(coords_list, width, height)
  case result {
    Ok(_) -> {
      let val =
        coords_list
        |> list.fold(0, fn(acc, coords: Coords) {
          int.bitwise_or(
            acc,
            int.bitwise_shift_left(1, width * coords.y + coords.x),
          )
        })
      Ok(Bitboard(width, height, val))
    }
    Error(message) -> Error(message)
  }
}

// To string
pub fn to_string(bitboard: Bitboard) -> String {
  bitboard.val
  |> int.to_base2
  |> string.pad_start(bitboard.width * bitboard.height, "0")
  |> string.split("")
  |> list.fold([""], fn(acc, str) {
    let assert [first, ..rest] = acc
    case string.length(first) >= bitboard.width {
      True -> [str, first, ..rest]
      False -> [str <> first, ..rest]
    }
  })
  |> list.reverse
  |> string.join("\n")
}

// Single row masks

fn first_row(bitboard: Bitboard, counter: Int, val: Int) -> Bitboard {
  case counter >= bitboard.width {
    True -> Bitboard(..bitboard, val: val)
    False -> {
      first_row(
        bitboard,
        counter + 1,
        int.bitwise_or(int.bitwise_shift_left(1, counter), val),
      )
    }
  }
}

pub fn row(bitboard: Bitboard, row_no: Int) -> Result(Bitboard, String) {
  use <- bool.guard(row_no < 0, Error("row_no must be positive"))
  use <- bool.guard(
    row_no >= bitboard.height,
    Error("row_no must be less than bitboard.height"),
  )

  let first_row = first_row(bitboard, 0, 0)
  let row = int.bitwise_shift_left(first_row.val, row_no * bitboard.width)
  Ok(Bitboard(..bitboard, val: row))
}

// Single column masks
fn first_col(bitboard: Bitboard, counter: Int, val: Int) -> Bitboard {
  case counter >= bitboard.height {
    True -> Bitboard(..bitboard, val: val)
    False -> {
      first_col(
        bitboard,
        counter + 1,
        int.bitwise_or(int.bitwise_shift_left(1, counter * bitboard.width), val),
      )
    }
  }
}

pub fn col(bitboard: Bitboard, col_no: Int) -> Result(Bitboard, String) {
  use <- bool.guard(col_no < 0, Error("col_no must be positive"))
  use <- bool.guard(
    col_no >= bitboard.width,
    Error("col_no must be less than bitboard.width"),
  )

  let first_col = first_col(bitboard, 0, 0)
  let col = int.bitwise_shift_left(first_col.val, col_no)
  Ok(Bitboard(..bitboard, val: col))
}

// Bitwise operations
pub fn and(
  bitboard_1: Bitboard,
  bitboard_2: Bitboard,
) -> Result(Bitboard, String) {
  case validate_equal_dimensions(bitboard_1, bitboard_2) {
    Error(err) -> Error(err)
    Ok(_) ->
      Ok(
        Bitboard(
          ..bitboard_1,
          val: int.bitwise_and(bitboard_1.val, bitboard_2.val),
        ),
      )
  }
}

pub fn or(
  bitboard_1: Bitboard,
  bitboard_2: Bitboard,
) -> Result(Bitboard, String) {
  case validate_equal_dimensions(bitboard_1, bitboard_2) {
    Error(err) -> Error(err)
    Ok(_) ->
      Ok(
        Bitboard(
          ..bitboard_1,
          val: int.bitwise_or(bitboard_1.val, bitboard_2.val),
        ),
      )
  }
}

pub fn not(bitboard: Bitboard) -> Bitboard {
  let full_board =
    int.bitwise_shift_left(1, bitboard.width * bitboard.height) - 1

  let val = int.bitwise_exclusive_or(bitboard.val, full_board)
  Bitboard(..bitboard, val: val)
}

// Shifts
pub fn shift_up(bitboard: Bitboard, by i: Int) -> Result(Bitboard, String) {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_up by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.height,
    Error("shift_up by must be < bitboard.height"),
  )

  let mask =
    list.range(bitboard.height - 1, bitboard.height - i)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = row(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_left(i * bitboard.width)
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_down(bitboard: Bitboard, by i: Int) -> Result(Bitboard, String) {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_down by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.height,
    Error("shift_down by must be < bitboard.height"),
  )

  let val = bitboard.val |> int.bitwise_shift_right(i * bitboard.width)
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_left(bitboard: Bitboard, by i: Int) -> Result(Bitboard, String) {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_left by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_left by must be < bitboard.width"),
  )

  let mask =
    list.range(0, i - 1)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = col(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_right(i)
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_right(bitboard: Bitboard, by i: Int) -> Result(Bitboard, String) {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_right by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_right by must be < bitboard.width"),
  )

  let mask =
    list.range(bitboard.width - 1, bitboard.width - i)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = col(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_left(i)
  Ok(Bitboard(..bitboard, val: val))
}

// Flips

pub fn flip_vertically(bitboard: Bitboard) -> Bitboard {
  let bitboard =
    list.range(0, bitboard.height - 1)
    |> list.fold(Bitboard(..bitboard, val: 0), fn(b, i) {
      let assert Ok(row_mask) = row(bitboard, i)
      let assert Ok(row) = and(bitboard, row_mask)
      let assert Ok(row) = shift_down(row, i)
      let assert Ok(row) = shift_up(row, bitboard.height - i - 1)
      let assert Ok(updated_bitboard) = or(b, row)
      updated_bitboard
    })
  bitboard
}
