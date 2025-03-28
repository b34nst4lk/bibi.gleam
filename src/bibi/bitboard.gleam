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
////
//// To disambiguate between the bitwise shift operations in the `int` modules and bitboard shifts
//// we use cardinal directions when describing and manipulating bitboards.
////
//// ```
////      north
////
////       000
//// west  000  east
////       000
////
////      south
//// ```
////

import gleam/bool
import gleam/int
import gleam/list
import gleam/string

import bibi/coords.{type Coords}

pub type Bitboard {
  Bitboard(width: Int, height: Int, val: Int)
}

type BitboardResult =
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

/// Create an empty bitboard of a given width and height
pub fn new(width: Int, height: Int) -> BitboardResult {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  Ok(Bitboard(width, height, 0))
}

/// Create a bitboard of a given width and height, and a binary string
///
/// i.e.
/// `from_base2(3, 3, "000000111")` --> `Bitboard(width: 3, height: 3, val: 7)`
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
/// i.e.
/// `from_coords(3, 3, Coords(0, 0))` --> `Bitboard(width: 3, height: 3, val: 1)`
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
/// i.e.
/// `from_coords(3, 3, [Coords(0, 0), Coords(1, 0)])` --> `Bitboard(width: 3, height: 3, val: 3)`
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

/// Create a bitboard of a given with and height, and the nth square
///
/// i.e. `from_square(3, 3, 1)` --> `Bitboard(width: 3, height: 3, val: 2)`
///
/// Squares are indexed from bottom left to top right. A 3 by 3 bitboard will be indexed as follows
/// ```
/// 6 7 8
/// 3 4 5
/// 0 1 2
/// ```
pub fn from_square(width, height, square) -> BitboardResult {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  use <- bool.guard(
    square > width * height,
    Error(
      "square ("
      <> int.to_string(square)
      <> ") must be less than width ("
      <> int.to_string(width)
      <> ") *"
      <> "height ("
      <> int.to_string(height)
      <> ")",
    ),
  )
  Ok(Bitboard(width, height, int.bitwise_shift_left(1, square)))
}

/// Create a bitboard of a given with and height, and a list of squares
///
/// i.e. `from_square(3, 3, [0, 1, 2])` --> `Bitboard(width: 3, height: 3, val: 7)`
///
/// Squares are indexed from bottom left to top right. A 3 by 3 bitboard will be indexed as follows
/// ```
/// 6 7 8
/// 3 4 5
/// 0 1 2
/// ```
pub fn from_squares(width, height, squares: List(Int)) -> BitboardResult {
  use <- bool.guard(width < 0, Error("width must be positive"))
  use <- bool.guard(height < 0, Error("height must be positive"))
  use <- bool.guard(
    list.any(squares, fn(square) { square > width * height }),
    Error(
      "squares must be less than width ("
      <> int.to_string(width)
      <> ") *"
      <> "height ("
      <> int.to_string(height)
      <> ")",
    ),
  )
  squares
  |> list.fold(0, fn(b, square) {
    int.bitwise_or(b, int.bitwise_shift_left(1, square))
  })
  |> Bitboard(width: width, height: height)
  |> Ok
}

/// Converts a bitboard into a width * height, breakpoint separated string of 1s and 0s
///
/// i.e. `to_string(Bitboard(width: 3, height: 3, val: 2))` -->
/// ```
/// 000
/// 000
/// 010
/// ````
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

/// Converts a bitboard into a list of integers representing where a square is occupied
///
/// i.e `to_squares(Bitboard(width: 3, height: 3, val: 3))` --> `[0, 1]`
pub fn to_squares(b: Bitboard) -> List(Int) {
  let result =
    list.range(0, b.width * b.height - 1)
    |> list.fold_until(#(b.val, []), fn(acc, i) {
      let #(board, l) = acc
      let l = case int.bitwise_and(1, board) > 0 {
        True -> [i, ..l]
        False -> l
      }
      let board = int.bitwise_shift_right(board, 1)
      case board > 0 {
        True -> list.Continue(#(board, l))
        False -> list.Stop(#(board, l))
      }
    })

  result.1
}

/// Convers a bitboard into a list of booleans representing where a square is occupied
///
/// i.e
/// `to_bools(Bitboard(width: 3, height: 3, val: 3))` --> `[True, True, False,... ]` (False repeats 7 times in this example)
pub fn to_bools(b: Bitboard) -> List(Bool) {
  list.range(0, b.width * b.height - 1)
  |> list.fold([], fn(acc, i) {
    let has_bit = int.bitwise_and(int.bitwise_shift_left(1, i), b.val) > 0
    list.append(acc, [has_bit])
  })
}

fn int_full_mask(b: Bitboard) -> Int {
  int.bitwise_shift_left(1, b.width * b.height) - 1
}

/// This returns a bitboard that is fully occupied
///
/// i.e.
/// ```
///                                  111
/// full_mask(Bitboard(3, 3, 1)) --> 111
///                                  111
/// ```
pub fn full_mask(b: Bitboard) -> Bitboard {
  Bitboard(..b, val: int_full_mask(b))
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

/// Returns a bitboard with the nth rank occupied of the provided bitboard.
/// Ranks are indexed from 0 to height - 1, and start from the north side of the board.
///
/// i.e.
/// ```
///                             000
/// rank(Bitboard(3, 3, 1)) --> 111
///                             000
/// ````
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

/// File Masks
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

/// Returns a bitboard with the nth file occupied of the provided bitboard
/// Files are indexed from 0 to width - 1, and start from the west side of the board
///
/// i.e.
/// ```
///                              010
/// file(Bitboard(3, 3, 1)) --> 010
///                              010
/// ````
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

/// Diagonals are made up of squares that touch at thr corners, and stretch from the
/// south eastern corner and towards the north western corner.
///
/// In rectangular bitboards, the diagonals will appear as follows
///
/// ```
/// 0010
/// 0100
/// 1000
/// ```
///
/// Diagonals are indexed in the `width + rank - file`. In a bitboard of width 3 and
/// height 4, the diagonals will be indexed as
/// ```
/// 5 . .
/// 4 . .
/// 3 . .
/// 2 1 0
/// ```
///
/// A diagonal of index 3 in the above bitboard will look like this
/// ```
/// 001
/// 010
/// 100
/// 000
/// ```
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

/// Antidiagonals are made up of squares that touch at thr corners, and stretch from the
/// south eastern corner and towards the north western corner.
///
/// In rectangular bitboards, the anti-diagonals will appear as follows
///
/// ```
/// 1000
/// 0100
/// 0010
/// ```
///
/// Antidiagonals are indexed in the `rank + file`. In a bitboard of width 3 and
/// height 4, the anti-diagonals will be indexed as
/// ```
/// . . 5
/// . . 4
/// . . 3
/// 0 1 2
/// ```
///
/// A anti-diagonal of index 3 in the above bitboard will look like this
/// ```
/// 100
/// 010
/// 001
/// 000
/// ```
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

/// Perfroms the `and` operation on two bitboards and returns a new bitboard.
/// If a square is occupied on both bitboards, it will be occupied in the
/// resulting bitboard. Both bitboards must have the same width and height.
/// ```
/// 010     000     000
/// 010 and 111 --> 010
/// 010     000     000
/// ```
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

/// Perfroms the `or` operation on two bitboards and returns a new bitboard.
/// If a square is occupied on both bitboards, it will be occupied in the
/// resulting bitboard. Both bitboards must have the same width and height.
/// ```
/// 010     000     010
/// 010 and 111 --> 111
/// 010     000     010
/// ```
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

/// Perfroms the `xor` operation on two bitboards and returns a new bitboard.
/// If a square is occupied only on on of the two  bitboards, it will be occupied in the
/// resulting bitboard. Both bitboards must have the same width and height.
/// ```
/// 010     000     010
/// 010 and 111 --> 101
/// 010     000     010
/// ```
pub fn bitboard_xor(
  bitboard_1: Bitboard,
  bitboard_2: Bitboard,
) -> BitboardResult {
  case validate_equal_dimensions(bitboard_1, bitboard_2) {
    Error(err) -> Error(err)
    Ok(_) ->
      Ok(
        Bitboard(
          ..bitboard_1,
          val: int.bitwise_exclusive_or(bitboard_1.val, bitboard_2.val),
        ),
      )
  }
}

/// Performs the `not` operation on a bitboard. All occupied squares will become unoccupied,
/// and vice versa.
///
/// i.e.
/// ```
/// 010    101
/// 101 -> 010
/// 010    101
/// ```
pub fn bitboard_not(bitboard: Bitboard) -> Bitboard {
  let full_board =
    int.bitwise_shift_left(1, bitboard.width * bitboard.height) - 1

  let val = int.bitwise_exclusive_or(bitboard.val, full_board)
  Bitboard(..bitboard, val: val)
}

/// Shifts the entire board towards the north by `i`
///
/// i.e. shift_north by 1
/// ````
/// 100    100
/// 100 -> 100
/// 100    000
/// ````
pub fn shift_north(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_north by must be >= 0"))
  Ok(shift_north_unvalidated(bitboard, i))
}

fn shift_north_unvalidated(bitboard: Bitboard, by i: Int) -> Bitboard {
  let val =
    bitboard.val
    |> int.bitwise_shift_left(i * bitboard.width)
    |> int.bitwise_and(int_full_mask(bitboard))
  Bitboard(..bitboard, val: val)
}

/// Shifts the entire board towards the south by `i`
///
/// i.e. shift_south by 1
/// ````
/// 100    000
/// 100 -> 100
/// 100    100
/// ````
pub fn shift_south(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_south by must be >= 0"))
  Ok(shift_south_unvalidated(bitboard, i))
}

fn shift_south_unvalidated(bitboard: Bitboard, by i: Int) -> Bitboard {
  let val =
    bitboard.val
    |> int.bitwise_shift_right(i * bitboard.width)
  Bitboard(..bitboard, val: val)
}

/// Shifts the entire board towards the west by `i`. Note that westwards
/// shifts will result in westmost occupied squares to be removed completely
///
/// i.e. shift_west by 1
/// ```
/// 111    110
/// 000 -> 000
/// 000    000
/// ```
pub fn shift_west(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_west by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_west by must be < bitboard.width"),
  )

  Ok(shift_west_unvalidated(bitboard, i))
}

fn shift_west_unvalidated(bitboard, by i) -> Bitboard {
  let mask =
    list.range(0, i - 1)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = file(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_right(i)
  Bitboard(..bitboard, val: val)
}

/// Shifts the entire board towards the east by `i`. Note that eastwards
/// shifts will result in eastmost occupied squares to be removed completely
///
/// i.e. shift_east by 1
/// ```
/// 111    011
/// 000 -> 000
/// 000    000
/// ```
pub fn shift_east(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_east by must be >= 0"))
  use <- bool.guard(
    i >= bitboard.width,
    Error("shift_east by must be < bitboard.width"),
  )

  Ok(shift_east_unvalidated(bitboard, i))
}

fn shift_east_unvalidated(bitboard: Bitboard, by i: Int) -> Bitboard {
  let mask =
    list.range(bitboard.width - 1, bitboard.width - i)
    |> list.fold(0, fn(m, i) {
      let assert Ok(r) = file(bitboard, i)
      int.bitwise_or(m, r.val)
    })
  let updated_val = bitboard.val - int.bitwise_and(mask, bitboard.val)
  let val = updated_val |> int.bitwise_shift_left(i)
  Bitboard(..bitboard, val: val)
}

/// Shifts the entire boards towards the northeast by `i`.
///
/// i.e. shift_northeast by 1
/// ```
/// 001    001
/// 011 -> 000
/// 000    000
/// ```
pub fn shift_northeast(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_northeast by must be >= 0"))
  bitboard
  |> shift_east_unvalidated(i)
  |> shift_north_unvalidated(i)
  |> Ok
}

/// Shifts the entire boards towards the northwest by `i`.
///
/// i.e. shift_northwest by 1
/// ```
/// 001    110
/// 011 -> 000
/// 000    000
/// ```
pub fn shift_northwest(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_northwest by must be >= 0"))
  bitboard
  |> shift_west_unvalidated(i)
  |> shift_north_unvalidated(i)
  |> Ok
}

/// Shifts the entire boards towards the southeast by `i`.
///
/// i.e. shift_southeast by 1
/// ```
/// 001    000
/// 011 -> 000
/// 000    001
/// ```
pub fn shift_southeast(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_southeast by must be >= 0"))
  bitboard
  |> shift_east_unvalidated(i)
  |> shift_south_unvalidated(i)
  |> Ok
}

/// Shifts the entire boards towards the southwest by `i`.
///
/// i.e. shift_southwest by 1
/// ```
/// 001    000
/// 011 -> 010
/// 000    110
/// ```
pub fn shift_southwest(bitboard: Bitboard, by i: Int) -> BitboardResult {
  use <- bool.guard(i == 0, Ok(bitboard))
  use <- bool.guard(i < 0, Error("shift_southwest by must be >= 0"))
  bitboard
  |> shift_west_unvalidated(i)
  |> shift_south_unvalidated(i)
  |> Ok
}

/// Flips a bitboard vertically
///
/// i.e
/// ````
/// 111    000
/// 000 -> 000
/// 000    111
/// ````
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

/// Flips a bitboard horizontally
///
/// i.e
/// ````
/// 100    001
/// 100 -> 001
/// 100    001
/// ````
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
