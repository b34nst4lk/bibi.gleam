import gleam/int
import gleam/list
import gleeunit/should

import bibi/bitboard.{Bitboard}
import bibi/coords.{Coords}

// Test bitboard creation from base2 string
pub fn successfully_create_bitboard_from_base2_string_test() {
  let test_cases = [#(3, 3, "111000000"), #(4, 3, "111000111")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(val) = int.base_parse(test_case.2, 2)
    should.equal(b.val, val)
  })
}

// Test bitboard creation with single coords
pub fn successfully_create_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), "000010000"),
    #(4, 3, Coords(1, 1), "000000100000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(b.val, expected)
  })
}

pub fn fail_to_create_bitboard_test() {
  let test_cases = [
    #(-1, 3, Coords(1, 1), "width must be positive"),
    #(3, -1, Coords(1, 1), "height must be positive"),
    #(3, 3, Coords(-1, 1), "Coords.x must be positive"),
    #(3, 3, Coords(4, 0), "Coords.x must be less than width"),
    #(3, 3, Coords(0, -1), "Coords.y must be positive"),
    #(3, 3, Coords(0, 4), "Coords.y must be less than height"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let result = bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    should.be_error(result)
    should.equal(result, Error(test_case.3))
  })
}

// Test bitboard creation with multiple coords
pub fn successfully_create_bitboard_from_coords_list_test() {
  let test_cases = [
    #(3, 3, [Coords(1, 1), Coords(0, 0)], "000010001"),
    #(3, 1, [Coords(1, 0), Coords(2, 0)], "110"),
    #(3, 1, [Coords(1, 0), Coords(2, 0), Coords(0, 0)], "111"),
    #(1, 3, [Coords(0, 0), Coords(0, 1), Coords(0, 2)], "111"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_list_of_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(b.val, expected)
  })
}

pub fn fail_to_create_bitboard_test_from_coords_list() {
  let test_cases = [
    #(-1, 3, [Coords(0, 0), Coords(1, 1)], "width must be positive"),
    #(3, -1, [Coords(0, 0), Coords(1, 1)], "height must be positive"),
    #(3, 3, [Coords(0, 0), Coords(-1, 1)], "Coords.x must be positive"),
    #(3, 3, [Coords(0, 0), Coords(4, 0)], "Coords.x must be less than width"),
    #(3, 3, [Coords(0, 0), Coords(0, -1)], "Coords.y must be positive"),
    #(3, 3, [Coords(0, 0), Coords(0, 4)], "Coords.y must be less than height"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let result =
      bitboard.from_list_of_coords(test_case.0, test_case.1, test_case.2)
    should.be_error(result)
    should.equal(result, Error(test_case.3))
  })
}

// Test converting bitboard from square
pub fn successfully_create_bitboard_from_square_test() {
  let test_cases = [#(3, 3, 0, "000000001"), #(3, 3, 1, "000000010")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_square(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(b.val, expected)
  })
}

// Test converting bitboard from squares
pub fn successfully_create_bitboard_from_squares_test() {
  let test_cases = [#(3, 3, [0, 1, 2], "000000111")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_squares(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(b.val, expected)
  })
}

// Test converting bitboard to string representation
pub fn successfully_bitboard_to_string_test() {
  let test_cases = [
    #(3, 3, "000111001", "000\n111\n100"),
    #(3, 3, "100000001", "001\n000\n100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let val = bitboard.to_string(b)
    should.equal(val, test_case.3)
  })
}

// Test deriving rank from bitboard
pub fn successfully_create_rank_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), 1, "000111000"),
    #(4, 3, Coords(0, 0), 0, "000000001111"),
    #(4, 3, Coords(0, 0), 2, "111100000000"),
    #(1, 3, Coords(0, 0), 0, "1"),
    #(3, 1, Coords(0, 0), 0, "111"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(rank) = bitboard.rank(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(rank.val, expected)
  })
}

pub fn fail_to_create_rank_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), -11, "rank_no must be positive"),
    #(4, 3, Coords(0, 0), 4, "rank_no must be less than bitboard.height"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let result = bitboard.rank(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test deriving fileumn from bitboard
pub fn successfully_create_file_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), 1, "010010010"),
    #(4, 3, Coords(0, 0), 0, "000100010001"),
    #(4, 3, Coords(0, 0), 1, "001000100010"),
    #(4, 3, Coords(0, 0), 2, "010001000100"),
    #(1, 3, Coords(0, 0), 0, "111"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(file) = bitboard.file(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(file.val, expected)
  })
}

pub fn fail_to_create_file_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), -11, "file_no must be positive"),
    #(4, 3, Coords(0, 0), 4, "file_no must be less than bitboard.width"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let result = bitboard.file(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test successfully create diagonal from bitboard
pub fn sucessfully_create_diagonal_from_bitboard_test() {
  let test_cases = [
    // #(3, 3, 4, "001000000"),
    // #(3, 3, 2, "100010001"),
    // #(3, 3, 3, "010001000"),
    #(4, 3, 1, "000010000100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let b = Bitboard(test_case.0, test_case.1, 0)
    let assert Ok(result) = bitboard.diagonal(b, test_case.2)
    let assert Ok(expected) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.3)
    should.equal(result, expected)
  })
}

// Test successfully create antidiagonal from bitboard
pub fn sucessfully_create_antidiagonal_from_bitboard_test() {
  let test_cases = [
    #(3, 3, 0, "000000001"),
    #(3, 3, 2, "001010100"),
    #(3, 3, 3, "010100000"),
    #(4, 3, 1, "10010"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let b = Bitboard(test_case.0, test_case.1, 0)
    let assert Ok(result) = bitboard.antidiagonal(b, test_case.2)
    let assert Ok(expected) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.3)
    should.equal(result, expected)
  })
}

// Test `bitboard_and` operator on bitboard
pub fn successfully_apply_and_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1)]),
      "010",
    ),
    #(
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "010",
    ),
    #(
      bitboard.from_list_of_coords(3, 4, [
        Coords(1, 0),
        Coords(2, 0),
        Coords(1, 1),
      ]),
      bitboard.from_list_of_coords(3, 4, [Coords(1, 0), Coords(2, 0)]),
      "000000000110",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Ok(result) = bitboard.bitboard_and(b1, b2)
    let assert Ok(expected) = int.base_parse(test_case.2, 2)
    should.equal(result.val, expected)
  })
}

pub fn fail_to_apply_and_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 2, [Coords(0, 1)]),
      "bitboard heights must be equal",
    ),
    #(
      bitboard.from_list_of_coords(4, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "bitboard widths must be equal",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Error(result) = bitboard.bitboard_and(b1, b2)
    should.equal(result, test_case.2)
  })
}

// Test `or` operator on bitboard
pub fn successfuly_apply_or_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1)]),
      "110",
    ),
    #(
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "110",
    ),
    #(
      bitboard.from_list_of_coords(3, 4, [
        Coords(1, 0),
        Coords(2, 0),
        Coords(1, 1),
      ]),
      bitboard.from_list_of_coords(3, 4, [Coords(1, 0), Coords(2, 0)]),
      "000000010110",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Ok(result) = bitboard.bitboard_or(b1, b2)
    let assert Ok(expected) = int.base_parse(test_case.2, 2)
    should.equal(result.val, expected)
  })
}

pub fn fail_to_apply_or_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 2, [Coords(0, 1)]),
      "bitboard heights must be equal",
    ),
    #(
      bitboard.from_list_of_coords(4, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "bitboard widths must be equal",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Error(result) = bitboard.bitboard_or(b1, b2)
    should.equal(result, test_case.2)
  })
}

// Test `or` operator on bitboard
pub fn successfuly_apply_xor_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1)]),
      "100",
    ),
    #(
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "100",
    ),
    #(
      bitboard.from_list_of_coords(3, 4, [
        Coords(1, 0),
        Coords(2, 0),
        Coords(1, 1),
      ]),
      bitboard.from_list_of_coords(3, 4, [Coords(1, 0), Coords(2, 0)]),
      "000000010000",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Ok(result) = bitboard.bitboard_xor(b1, b2)
    let assert Ok(expected) = int.base_parse(test_case.2, 2)
    should.equal(result.val, expected)
  })
}

pub fn fail_to_apply_xor_on_bitboards_test() {
  let test_cases = [
    #(
      bitboard.from_list_of_coords(1, 3, [Coords(0, 1), Coords(0, 2)]),
      bitboard.from_list_of_coords(1, 2, [Coords(0, 1)]),
      "bitboard heights must be equal",
    ),
    #(
      bitboard.from_list_of_coords(4, 1, [Coords(1, 0), Coords(2, 0)]),
      bitboard.from_list_of_coords(3, 1, [Coords(1, 0)]),
      "bitboard widths must be equal",
    ),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b1) = test_case.0
    let assert Ok(b2) = test_case.1
    let assert Error(result) = bitboard.bitboard_xor(b1, b2)
    should.equal(result, test_case.2)
  })
}

// Test bitboard_not operator
pub fn successfully_apply_not_on_bitboard_test() {
  let test_cases = [
    #(5, 5, Coords(2, 2), "1111111111110111111111111"),
    #(1, 1, Coords(0, 0), "0"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(bitboard) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(
      bitboard.bitboard_not(bitboard),
      Bitboard(..bitboard, val: expected),
    )
  })
}

// Test shift south
pub fn successfully_shift_south_bitboard_test() {
  let test_cases = [
    #(3, 3, "111000000", 2, "000000111"),
    #(3, 3, "111000000", 1, "000111000"),
    #(3, 3, "000000111", 1, "000000000"),
    #(3, 3, "000000111", 0, "000000111"),
    #(4, 3, "100010001000", 1, "000010001000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_south(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_south_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_south by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_south(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift north
pub fn successfully_shift_north_bitboard_test() {
  let test_cases = [
    #(3, 3, "000000111", 2, "111000000"),
    #(3, 3, "000000111", 1, "000111000"),
    #(3, 3, "111000000", 1, "000000000"),
    #(4, 3, "100010001000", 1, "100010000000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_north(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_north_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_north by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_north(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift west
pub fn successfully_shift_west_bitboard_test() {
  let test_cases = [
    #(3, 3, "000000111", 2, "000000001"),
    #(3, 3, "000000111", 1, "000000011"),
    #(3, 3, "111000000", 1, "011000000"),
    #(4, 3, "100010001000", 1, "010001000100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_west(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_west_bitboard_test() {
  let test_cases = [
    #(3, 3, "000000111", 10, "shift_west by must be < bitboard.width"),
    #(3, 3, "000000111", 3, "shift_west by must be < bitboard.width"),
    #(3, 3, "000000111", -1, "shift_west by must be >= 0"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_west(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

//Test shift east
pub fn successfully_shift_east_bitboard_test() {
  let test_cases = [
    #(3, 3, "000000111", 2, "000000100"),
    #(3, 3, "000000111", 1, "000000110"),
    #(3, 3, "111000000", 1, "110000000"),
    #(4, 3, "100010001000", 1, "000000000000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_east(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_east_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_east by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_east(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift northeast
pub fn successfully_shift_northeast_bitboard_test() {
  let test_cases = [
    #(3, 3, "000010000", 0, "000010000"),
    #(3, 3, "000010000", 1, "100000000"),
    #(3, 3, "000010000", 2, "000000000"),
    #(3, 4, "000010000000", 1, "100000000000"),
    #(3, 4, "000011000000", 1, "110000000000"),
    #(4, 3, "000000000001", 1, "000000100000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_northeast(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_northeast_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_northeast by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_northeast(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift northwest
pub fn successfully_shift_northwest_bitboard_test() {
  let test_cases = [
    #(3, 3, "000010000", 0, "000010000"),
    #(3, 3, "000010000", 1, "001000000"),
    #(3, 3, "000010000", 2, "000000000"),
    #(3, 4, "000010000000", 1, "001000000000"),
    #(3, 4, "000011000000", 1, "001000000000"),
    #(4, 3, "000000000100", 1, "000000100000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_northwest(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_northwest_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_northwest by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_northwest(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift southeast
pub fn successfully_shift_southeast_bitboard_test() {
  let test_cases = [
    #(3, 3, "000010000", 0, "000010000"),
    #(3, 3, "000010000", 1, "000000100"),
    #(3, 3, "000010000", 2, "000000000"),
    #(3, 4, "000010000000", 1, "000000100000"),
    #(3, 4, "000011000000", 1, "000000110000"),
    #(4, 3, "000000100000", 1, "000000000100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_southeast(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_southeast_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_southeast by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_southeast(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test shift southwest
pub fn successfully_shift_southwest_bitboard_test() {
  let test_cases = [
    #(3, 3, "000010000", 0, "000010000"),
    #(3, 3, "000010000", 1, "000000001"),
    #(3, 3, "000010000", 2, "000000000"),
    #(3, 4, "000010000000", 1, "000000001000"),
    #(3, 4, "000011000000", 1, "000000001000"),
    #(4, 3, "000000100000", 1, "000000000001"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_southwest(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_southwest_bitboard_test() {
  let test_cases = [#(3, 3, "000000111", -1, "shift_southwest by must be >= 0")]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_southwest(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test flip vertically
pub fn successfully_flip_vertically_test() {
  let test_cases = [
    #(3, 3, "000000111", "111000000"),
    #(3, 3, "000111000", "000111000"),
    #(3, 3, "100000001", "001000100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    let updated_bitboard = bitboard.flip_vertically(b)
    should.equal(updated_bitboard.val, expected)
  })
}

// Test flip horizontally
pub fn successfully_flip_horizontally_test() {
  let test_cases = [
    #(3, 3, "000000111", "000000111"),
    #(3, 3, "000111000", "000111000"),
    #(3, 3, "001001001", "100100100"),
    #(3, 3, "000111000", "000111000"),
    #(3, 3, "100000001", "001000100"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    let updated_bitboard = bitboard.flip_horizontally(b)
    should.equal(updated_bitboard.val, expected)
  })
}
