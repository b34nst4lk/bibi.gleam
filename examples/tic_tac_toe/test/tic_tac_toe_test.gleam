import gleam/int
import gleam/io
import gleam/list
import gleeunit
import gleeunit/should

import tic_tac_toe.{
  type Move, Draw, NotEnded, Winner, has_ended, minimax, new_game, to_char,
  to_string,
}

type GameEndTestCase {
  GameEndTestCase(moves: List(Move), expected: String)
}

pub fn game_end_test() {
  let test_cases = [
    GameEndTestCase([0, 1, 3, 4, 6], "X"),
    GameEndTestCase([0, 1, 3, 4, 8, 7], "O"),
    GameEndTestCase([], "Not Ended"),
    GameEndTestCase([0, 1, 2, 4, 3, 6, 5, 8, 7], "Draw"),
  ]
  test_cases
  |> list.map(fn(test_case) {
    let game = new_game()
    let game =
      test_case.moves
      |> list.fold(game, fn(g, move) { tic_tac_toe.update_game(g, move) })
    io.println(to_string(game))
    case has_ended(game) {
      NotEnded(_) -> should.equal(test_case.expected, "Not Ended")
      Draw(_) -> should.equal(test_case.expected, "Draw")
      Winner(_, winner) -> should.equal(to_char(winner), test_case.expected)
    }
  })
}

type MinimaxTestCase {
  MinimaxTextCase(moves: List(Move), expected: Move)
}

pub fn minimax_must_pick_test() {
  let test_cases = [
    MinimaxTextCase([0, 1, 3, 4], 6),
    MinimaxTextCase([8, 7, 5], 2),
  ]
  test_cases
  |> list.map(fn(test_case) {
    // Setup game
    let game = new_game()
    let game =
      test_case.moves
      |> list.fold(game, fn(g, move) { tic_tac_toe.update_game(g, move) })
    io.println(to_string(game))
    io.debug(game)
    let move = minimax(game)
    io.println(int.to_string(move))
    should.equal(move, test_case.expected)
  })
}

pub fn minimax_should_not_pick_test() {
  let test_cases: List(MinimaxTestCase) = [
    MinimaxTextCase([4, 8], 0),
    MinimaxTextCase([8, 7], 6),
  ]
  test_cases
  |> list.map(fn(test_case) {
    // Setup game
    let game = new_game()
    let game =
      test_case.moves
      |> list.fold(game, fn(g, move) { tic_tac_toe.update_game(g, move) })
    let move = minimax(game)
    should.not_equal(move, test_case.expected)
  })
}

pub fn main() {
  let _ = gleeunit.main()
}
