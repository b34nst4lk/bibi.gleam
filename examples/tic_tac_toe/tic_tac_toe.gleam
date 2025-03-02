import gleam/io
import gleam/list
import gleam/order
import gleam/string

import bibi/bitboard as b

const width = 3

const height = 3

pub type Move =
  Int

pub type Strategy =
  fn(Game) -> Move

pub type Turn {
  X(b: b.Bitboard, strategy: Strategy)
  O(b: b.Bitboard, strategy: Strategy)
}

pub fn to_char(turn: Turn) -> String {
  case turn {
    X(_, _) -> "X"
    O(_, _) -> "O"
  }
}

pub type GameEnd {
  Winner(game: Game, t: Turn)
  Draw(game: Game)
  NotEnded(game: Game)
}

pub fn to_string(game: Game) -> String {
  let active = b.to_bools(game.active.b)
  let inactive = b.to_bools(game.inactive.b)
  let output =
    list.zip(active, inactive)
    |> list.index_fold(#("", []), fn(acc, tups, i) {
      let #(line, board) = acc
      let char = case tups {
        #(True, False) -> to_char(game.active)
        #(False, True) -> to_char(game.inactive)
        #(_, _) -> "_"
      }
      case i % width {
        0 -> #(char, board)
        1 -> #(line <> " | " <> char, board)
        2 -> #("", [line <> " | " <> char, ..board])

        _ -> #("", [])
      }
    })

  output.1
  |> string.join("\n- + - + -\n")
}

pub fn update_turn(t: Turn, next_move: Move) {
  let assert Ok(bitboard_of_move) = b.from_square(width, height, next_move)
  let assert Ok(updated_bitboard) = b.bitboard_or(t.b, bitboard_of_move)

  case t {
    X(_, strategy) -> X(updated_bitboard, strategy)
    O(_, strategy) -> O(updated_bitboard, strategy)
  }
}

pub type Game {
  Game(active: Turn, inactive: Turn)
}

pub fn new_game() -> Game {
  let assert Ok(x) = b.new(width, height)
  let assert Ok(o) = b.new(width, height)
  Game(active: X(x, random), inactive: O(o, minimax))
}

fn available_moves(game: Game) -> List(Move) {
  let assert Ok(full_board) = b.bitboard_or(game.active.b, game.inactive.b)
  let available_board = b.bitboard_not(full_board)
  b.to_squares(available_board)
}

pub fn random(game: Game) -> Move {
  let assert Ok(next_move) = available_moves(game) |> list.shuffle |> list.first
  next_move
}

fn check_win(b: b.Bitboard) -> Bool {
  [
    b.rank(b, 0),
    b.rank(b, 1),
    b.rank(b, 2),
    b.file(b, 0),
    b.file(b, 1),
    b.file(b, 2),
    b.diagonal(b, 2),
    b.antidiagonal(b, 2),
  ]
  |> list.map(fn(mask_result) {
    let assert Ok(mask) = mask_result
    let assert Ok(masked) = b.bitboard_and(mask, b)

    masked == mask
  })
  |> list.any(fn(b) { b })
}

pub fn has_ended(game: Game) -> GameEnd {
  let active_is_winner = check_win(game.active.b)

  let inactive_is_winner = check_win(game.inactive.b)

  case active_is_winner, inactive_is_winner {
    True, False -> Winner(game, game.active)
    False, True -> Winner(game, game.inactive)
    _, _ ->
      case available_moves(game) {
        [] -> Draw(game)
        _ -> NotEnded(game)
      }
  }
}

pub fn update_game(game: Game, move: Move) {
  let updated_turn = update_turn(game.active, move)
  Game(active: game.inactive, inactive: updated_turn)
}

pub fn run(game: Game, round: Int) -> GameEnd {
  let next_move = game.active.strategy(game)
  let updated_game = update_game(game, next_move)
  io.println("Turn: " <> to_char(game.active))
  io.println(to_string(updated_game))
  case has_ended(updated_game) {
    NotEnded(_) -> run(updated_game, round + 1)
    result -> result
  }
}

pub fn simulate_game() {
  let result = run(new_game(), 0)
  io.println("result")
  io.debug(result)
  io.print(to_string(result.game))
}

/// strategies
fn score(game_end: GameEnd, depth: Int) -> Int {
  case game_end {
    NotEnded(_) | Draw(_) -> 0
    Winner(_, _) -> 10 - depth
  }
}

pub fn minimax(game: Game) {
  let move = minimax_iter(game, 0, to_char(game.active)).0
  move
}

fn compare_moves(move1: #(Move, Int), move2: #(Move, Int)) -> order.Order {
  case move1.1 == move2.1 {
    True -> order.Eq
    False ->
      case move1.1 < move2.1 {
        True -> order.Lt
        False -> order.Gt
      }
  }
}

fn minimax_iter(game: Game, depth: Int, player: String) -> #(Move, Int) {
  // Get the score of each move
  let moves_and_scores =
    available_moves(game)
    |> list.fold([], fn(scores, move) {
      let updated_game = update_game(game, move)
      let has_game_ended = has_ended(updated_game)

      let score = case has_game_ended {
        Winner(_, winner) ->
          case to_char(winner) == player {
            True -> score(has_game_ended, depth)
            False -> -score(has_game_ended, depth)
          }
        Draw(_) -> 0
        NotEnded(_) -> minimax_iter(updated_game, depth + 1, player).1
      }
      [#(move, score), ..scores]
    })

  let assert Ok(best_move) =
    moves_and_scores
    |> list.max(fn(move1, move2) {
      case player == to_char(game.active) {
        True -> compare_moves(move1, move2)
        False -> order.negate(compare_moves(move1, move2))
      }
    })
  best_move
}

fn main() {
  run(new_game())
}
