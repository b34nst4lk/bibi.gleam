import gleam/io
import gleam/list
import gleam/order
import gleam/string

import bibi/bitboard as b

const width = 7

const height = 6

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
        1 | 2 | 3 | 4 | 5 -> #(line <> " | " <> char, board)
        6 -> #("", [line <> " | " <> char, ..board])

        _ -> #("", [])
      }
    })

  output.1
  |> string.join("\n- + - + - + - + - + - + -\n")
}

pub fn update_turn(g: Game, next_move: Move) {
  let assert Ok(full_board) = b.bitboard_or(g.active.b, g.inactive.b)
  let assert Ok(mask) = b.file(full_board, next_move)
  let assert Ok(col) = b.bitboard_and(full_board, mask)
  let assert Ok(empty_slots) = b.bitboard_xor(col, mask)
  let assert Ok(square) = empty_slots |> b.to_squares |> list.last

  let assert Ok(bitboard_of_move) = b.from_square(width, height, square)
  let assert Ok(updated_bitboard) = b.bitboard_or(g.active.b, bitboard_of_move)

  case g.active {
    X(_, strategy) -> X(updated_bitboard, strategy)
    O(_, strategy) -> O(updated_bitboard, strategy)
  }
}

pub type Game {
  Game(active: Turn, inactive: Turn)
}

fn available_moves(game: Game) -> List(Move) {
  let assert Ok(full_board) = b.bitboard_or(game.active.b, game.inactive.b)
  let moves =
    list.range(0, width - 1)
    |> list.fold([], fn(moves, i: Int) {
      let assert Ok(mask) = b.file(game.active.b, i)
      let assert Ok(file) = b.bitboard_and(full_board, mask)
      case file != mask {
        True -> list.append(moves, [i])
        False -> moves
      }
    })
  moves
}

pub fn random(game: Game) -> Move {
  let assert Ok(next_move) = available_moves(game) |> list.shuffle |> list.first
  next_move
}

fn check_consecutive_pieces_in_one_direction(
  turn: Turn,
  shift: fn(b.Bitboard, Int) -> Result(b.Bitboard, String),
  iterations: Int,
) -> Bool {
  let final_board =
    list.range(0, iterations - 1)
    |> list.fold(turn.b, fn(board, i) {
      let assert Ok(shifted_board) = shift(turn.b, i)
      let assert Ok(board) = b.bitboard_and(board, shifted_board)
      board
    })
  final_board.val > 0
}

fn check_win(turn: Turn) -> Bool {
  [b.shift_east, b.shift_north, b.shift_northeast, b.shift_northwest]
  |> list.map(fn(shift) {
    check_consecutive_pieces_in_one_direction(turn, shift, 4)
  })
  |> list.any(fn(b) { b })
}

pub fn has_ended(game: Game) -> GameEnd {
  let active_is_winner = check_win(game.active)

  let inactive_is_winner = check_win(game.inactive)

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
  let updated_turn = update_turn(game, move)
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

/// strategies
fn score(game_end: GameEnd, depth: Int) -> Int {
  case game_end {
    NotEnded(_) | Draw(_) -> 0
    Winner(_, _) -> 10 - depth
  }
}

pub fn minimax(game: Game, max_depth: Int) {
  let move = minimax_iter(game, 0, to_char(game.active), max_depth).0
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

fn minimax_iter(
  game: Game,
  depth: Int,
  player: String,
  max_depth: Int,
) -> #(Move, Int) {
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
        NotEnded(_) ->
          case depth >= max_depth {
            False -> minimax_iter(updated_game, depth + 1, player, max_depth).1
            True -> 0
          }
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

  let assert Ok(random_best_move) =
    moves_and_scores
    |> list.filter(fn(move_and_score) { move_and_score.1 == best_move.1 })
    |> list.shuffle
    |> list.first

  random_best_move
}

pub fn new_game() -> Game {
  let assert Ok(x) = b.new(width, height)
  let assert Ok(o) = b.new(width, height)
  Game(active: X(x, minimax(_, 5)), inactive: O(o, random))
  // minimax(_, 3)))
}

pub fn main() {
  let result = run(new_game(), 0)
  io.println("result")
  io.debug(result)
  io.print(to_string(result.game))
}
