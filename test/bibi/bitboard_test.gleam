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

// Test deriving row from bitboard
pub fn successfully_create_row_from_bitboard_test() {
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
    let assert Ok(row) = bitboard.row(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(row.val, expected)
  })
}

pub fn fail_to_create_row_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), -11, "row_no must be positive"),
    #(4, 3, Coords(0, 0), 4, "row_no must be less than bitboard.height"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let result = bitboard.row(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test deriving column from bitboard
pub fn successfully_create_col_from_bitboard_test() {
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
    let assert Ok(col) = bitboard.col(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(col.val, expected)
  })
}

pub fn fail_to_create_col_from_bitboard_test() {
  let test_cases = [
    #(3, 3, Coords(1, 1), -11, "col_no must be positive"),
    #(4, 3, Coords(0, 0), 4, "col_no must be less than bitboard.width"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_coords(test_case.0, test_case.1, test_case.2)
    let result = bitboard.col(b, test_case.3)
    should.equal(result, Error(test_case.4))
  })
}

// Test `and` operator on bitboard
pub fn successfuly_apply_and_on_bitboards_test() {
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
    let assert Ok(result) = bitboard.and(b1, b2)
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
    let assert Error(result) = bitboard.and(b1, b2)
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
    let assert Ok(result) = bitboard.or(b1, b2)
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
    let assert Error(result) = bitboard.or(b1, b2)
    should.equal(result, test_case.2)
  })
}

// Test not operator
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
    should.equal(bitboard.not(bitboard), Bitboard(..bitboard, val: expected))
  })
}

// Test shift down
pub fn successfully_shift_down_bitboard_test() {
  let test_cases = [
    #(3, 3, "111000000", 2, "000000111"),
    #(3, 3, "111000000", 1, "000111000"),
    #(3, 3, "000000111", 1, "000000000"),
    #(4, 3, "100010001000", 1, "000010001000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    let assert Ok(updated_bitboard) = bitboard.shift_down(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

// Test shift up
pub fn successfully_shift_up_bitboard_test() {
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
    let assert Ok(updated_bitboard) = bitboard.shift_up(b, test_case.3)
    should.equal(updated_bitboard.val, expected)
  })
}

pub fn fail_to_shift_up_bitboard_test() {
  let test_cases = [
    #(3, 3, "000000111", 10, "shift_up by must be < bitboard.height"),
    #(3, 3, "000000111", 3, "shift_up by must be < bitboard.height"),
    #(3, 3, "000000111", -1, "shift_up by must be >= 0"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) =
      bitboard.from_base2(test_case.0, test_case.1, test_case.2)
    let result = bitboard.shift_up(b, test_case.3)
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
