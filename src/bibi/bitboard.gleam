//// The bibi/bitboard module provides the ability to create and manipulate bitboards

import gleam/bool
import gleam/list

import gleam/int

import bibi/coords.{type Coords}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

pub fn from_coords(
  width: Int,
  height: Int,
  coords: Coords,
) -> Result(Bitboard, String) {
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
