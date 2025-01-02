import gleam/int
import gleam/list
import gleeunit
import gleeunit/should

import bibi

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn successfully_create_bitboard_test() {
  let test_cases = [
    #(3, 3, bibi.Coords(1, 1), "000010000"),
    #(4, 3, bibi.Coords(1, 1), "000000100000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) = bibi.from_coords(test_case.0, test_case.1, test_case.2)
    let assert Ok(expected) = int.base_parse(test_case.3, 2)
    should.equal(b.val, expected)
  })
}

pub fn fail_to_create_bitboard_test() {
  let test_cases = [
    #(-1, 3, bibi.Coords(1, 1), "width must be positive"),
    #(3, -1, bibi.Coords(1, 1), "height must be positive"),
    #(3, 3, bibi.Coords(-1, 1), "x coords must be positive"),
    #(3, 3, bibi.Coords(4, 0), "x coords must be less than width"),
    #(3, 3, bibi.Coords(0, -1), "y coords must be postive"),
    #(3, 3, bibi.Coords(0, 4), "y coords must be less than height"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let result = bibi.from_coords(test_case.0, test_case.1, test_case.2)
    should.be_error(result)
    let assert Error(err) = result
    should.equal(err.message, test_case.3)
  })
}

pub fn successfully_create_row_from_bitboard_test() {
  let test_cases = [
    #(3, 3, bibi.Coords(1, 1), 1, "000111000"),
    #(4, 3, bibi.Coords(0, 0), 0, "000000001111"),
    #(4, 3, bibi.Coords(0, 0), 2, "111100000000"),
    #(4, 3, bibi.Coords(0, 0), 3, "1111000000000000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) = bibi.from_coords(test_case.0, test_case.1, test_case.2)
    let row = bibi.row(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(row.val, expected)
  })
}

pub fn successfully_create_col_from_bitboard_test() {
  let test_cases = [
    #(3, 3, bibi.Coords(1, 1), 1, "010010010"),
    #(4, 3, bibi.Coords(0, 0), 0, "000100010001"),
    #(4, 3, bibi.Coords(0, 0), 2, "010001000100"),
    #(4, 3, bibi.Coords(0, 0), 3, "100010001000"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let assert Ok(b) = bibi.from_coords(test_case.0, test_case.1, test_case.2)
    let row = bibi.col(b, test_case.3)
    let assert Ok(expected) = int.base_parse(test_case.4, 2)
    should.equal(row.val, expected)
  })
}
