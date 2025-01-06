import gleam/int
import gleam/list
import gleeunit/should

import bibi/bitboard
import bibi/coords.{Coords}

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
