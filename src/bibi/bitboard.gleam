//// The bibi/bitboard module provides the ability to create and manipulate bitboards.
//// Bitboards have a defined width and height, and an integer that represents the
//// state of the bitboard when in binary
////
//// Suppose you are representing a game of tic-tac-toe that looks like
////
////```
//// X | O | _
//// - + - + -
//// O | X | _
//// - + - + -
//// O | _ | X
//// ```
//// Representing the X's as a bitboard, it would look like
//// ```
//// 100
//// 010
//// 001
//// ```
////
//// In binary, this would be `001010100`, which translates to 84
////
//// Notice that the positions of the 1's when the bitboard is translated into its
//// binary integer format
////
//// The following diagram shows how the individual bits are ordered from right to left
//// ```
//// 6 7 8
//// 3 4 5
//// 0 1 2
//// ```

import gleam/bool
import gleam/int
import gleam/list
import gleam/string

import bibi/coords.{type Coords}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

pub type BitboardResult =
  Result(Bitboard, String)

/// Internal validator for ensuring bitboards are of the same dimension before bitboard
/// operations are performed
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

/// Internal validator for ensuring that coordinates are on the bitboard before
/// bitboard operations are performed
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

/// Internal validator for ensuring that coordinates are on the bitboard before
/// bitboard operations are performed
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

/// Create a bitboard of a given width and height, and a binary string
///
/// I.e `from_base2(3, 3, "000000111")` --> `Bitboard(width: 3, height: 3, val: 7)`
pub fn from_base2(width: Int, height: Int, bits: String) -> BitboardResult {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))

  let assert Ok(val) = int.base_parse(bits, 2)
  use <- bool.guard(
    val >= int.bitwise_shift_left(1, width * height),
    Error("bits must be less than 1 << width * height"),
  )
  Ok(Bitboard(width, height, val))
}

/// Create a bitboard of a given width and height, and a Coords
///
/// I.e `from_coords(3, 3, Coords(0, 0))` --> `Bitboard(width: 3, height: 3, val: 1)`
pub fn from_coords(width: Int, height: Int, coords: Coords) -> BitboardResult {
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

/// Create a bitboard of a given width and height, and a list of Coords
///
/// I.e `from_coords(3, 3, [Coords(0, 0), Coords(1, 0)])` --> `Bitboard(width: 3, height: 3, val: 3)`
pub fn from_list_of_coords(
  width: Int,
  height: Int,
  coords_list: List(Coords),
) -> BitboardResult {
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

/// Converts a bitboard into a
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

/// Full mask
fn full_mask(b: Bitboard) -> Int {
  int.bitwise_shift_left(1, b.width * b.height) - 1
}

// Single rank masks
fn first_rank(bitboard: Bitboard, counter: Int, val: Int) -> Bitboard {
  case counter >= bitboard.width {
    True -> Bitboard(..bitboard, val: val)
    False -> {
      first_rank(
        bitboard,
        counter + 1,
        int.bitwise_or(int.bitwise_shift_left(1, counter), val),
      )
    }
  }
}

pub fn rank(bitboard: Bitboard, rank_no: Int) -> BitboardResult {
  use <- bool.guard(rank_no < 0, Error("rank_no must be positive"))
  use <- bool.guard(
    rank_no >= bitboard.height,
    Error("rank_no must be less than bitboard.height"),
  )

  let first_rank = first_rank(bitboard, 0, 0)
  let rank = int.bitwise_shift_left(first_rank.val, rank_no * bitboard.width)
  Ok(Bitboard(..bitboard, val: rank))
}

/// Col Masks
fn first_file(bitboard: Bitboard, counter: Int, val: Int) -> Bitboard {
  case counter >= bitboard.height {
    True -> Bitboard(..bitboard, val: val)
    False -> {
      first_file(
        bitboard,
        counter + 1,
        int.bitwise_or(int.bitwise_shift_left(1, counter * bitboard.width), val),
      )
    }
  }
}

pub fn file(bitboard: Bitboard, file_no: Int) -> BitboardResult {
  use <- bool.guard(file_no < 0, Error("file_no must be positive"))
  use <- bool.guard(
    file_no >= bitboard.width,
    Error("file_no must be less than bitboard.width"),
  )

  let first_file = first_file(bitboard, 0, 0)
  let file = int.bitwise_shift_left(first_file.val, file_no)
  Ok(Bitboard(..bitboard, val: file))
}

fn diagonal_from_south_west(b: Bitboard) -> Bitboard {
  let length = int.min(b.width, b.height)
  let val =
    list.range(0, length - 1)
    |> list.fold(0, fn(acc, i) {
      let new_bit = int.bitwise_shift_left(1, b.width * i + i)
      int.bitwise_or(acc, new_bit)
    })
  Bitboard(..b, val: val)
}

fn antidiagonal_from_south_east(b: Bitboard) -> Bitboard {
  let length = int.min(b.width, b.height)
  let seed = int.bitwise_shift_left(1, b.width - 1)
  let val =
    list.range(0, length - 1)
    |> list.fold(0, fn(acc, _) {
      let acc = int.bitwise_shift_left(acc, b.width - 1)
      int.bitwise_or(acc, seed)
    })
  let b = Bitboard(..b, val: val)
  b
}

// Single diagonal mask
pub fn diagonal(bitboard: Bitboard, diagonal_no: Int) -> BitboardResult {
  let max_diagonal_no = bitboard.width + bitboard.height - 2

  use <- bool.guard(diagonal_no < 0, Error("diagonal_no must be positive"))
  use <- bool.guard(
    diagonal_no > max_diagonal_no,
    Error("diagonal_no must be less than bitboard.width + bitboard.height - 1"),
  )

  let main_diagonal = diagonal_from_south_west(bitboard)
  case diagonal_no < bitboard.width, bitboard.width < bitboard.height {
    True, True -> shift_south(main_diagonal, bitboard.width - diagonal_no - 1)
    True, False -> shift_east(main_diagonal, bitboard.width - diagonal_no - 1)
    False, True -> shift_north(main_diagonal, diagonal_no - bitboard.width + 1)
    False, False -> shift_west(main_diagonal, diagonal_no - bitboard.width + 1)
  }
}

// Single antidiagonal mask
pub fn antidiagonal(bitboard: Bitboard, antidiagonal_no: Int) -> BitboardResult {
  let max_antidiagonal_no = bitboard.width + bitboard.height - 2

  use <- bool.guard(
    antidiagonal_no < 0,
    Error("antidiagonal_no must be positive"),
  )
  use <- bool.guard(
    antidiagonal_no > max_antidiagonal_no,
    Error(
      "antidiagonal_no must be less than bitboard.width + bitboard.height - 1",
    ),
  )

  let main_diagonal = antidiagonal_from_south_east(bitboard)
  case antidiagonal_no < bitboard.width, bitboard.width < bitboard.height {
    True, True ->
      shift_south(main_diagonal, bitboard.width - antidiagonal_no - 1)
    True, False ->
      shift_west(main_diagonal, bitboard.width - antidiagonal_no - 1)
    False, True ->
      shift_north(main_diagonal, antidiagonal_no - bitboard.width + 1)
    False, False ->
      shift_east(main_diagonal, antidiagonal_no - bitboard.width + 1)
  }
}

/// Bitwise operations
pub fn bitboard_and(
  bitboard_1: Bitboard,
  bitboard_2: Bitboard,
) -> BitboardResult {
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

pub fn bitboard_or(bitboard_1: Bitboard, bitboard_2: Bitboard) -> BitboardResult {
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

pub fn bitboard_not(bitboard: Bitboard) -> Bitboard {
  let full_board =
    int.bitwise_shift_left(1, bitboard.width * bitboard.height) - 1

  let val = int.bitwise_exclusive_or(bitboard.val, full_board)
  Bitboard(..bitboard, val: val)
}

// Shifts
pub fn shift_north(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_north by must be >= 0"))
  let val =
    bitboard.val
    |> int.bitwise_shift_left(i * bitboard.width)
    |> int.bitwise_and(full_mask(bitboard))
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_south(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_south by must be >= 0"))
  let val =
    bitboard.val
    |> int.bitwise_shift_right(i * bitboard.width)
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_west(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_west by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_west by must be < bitboard.width"),
  )

  let mask =
    list.range(0, i - 1)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = file(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_right(i)
  Ok(Bitboard(..bitboard, val: val))
}

pub fn shift_east(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_east by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_east by must be < bitboard.width"),
  )

  let mask =
    list.range(bitboard.width - 1, bitboard.width - i)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = file(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_left(i)
  Ok(Bitboard(..bitboard, val: val))
}

// Flips
pub fn flip_vertically(bitboard: Bitboard) -> Bitboard {
  list.range(0, bitboard.height - 1)
  |> list.fold(Bitboard(..bitboard, val: 0), fn(b, i) {
    let assert Ok(rank_mask) = rank(bitboard, i)
    let assert Ok(rank) = bitboard_and(bitboard, rank_mask)
    let assert Ok(rank) = shift_south(rank, i)
    let assert Ok(rank) = shift_north(rank, bitboard.height - i - 1)
    let assert Ok(updated_bitboard) = bitboard_or(b, rank)
    updated_bitboard
  })
}

pub fn flip_horizontally(bitboard: Bitboard) -> Bitboard {
  list.range(0, bitboard.width - 1)
  |> list.fold(Bitboard(..bitboard, val: 0), fn(b, i) {
    let assert Ok(file_mask) = file(bitboard, i)
    let assert Ok(file) = bitboard_and(bitboard, file_mask)
    let assert Ok(file) = shift_west(file, i)
    let assert Ok(file) = shift_east(file, bitboard.width - i - 1)
    let assert Ok(updated_bitboard) = bitboard_or(b, file)
    updated_bitboard
  })
}
