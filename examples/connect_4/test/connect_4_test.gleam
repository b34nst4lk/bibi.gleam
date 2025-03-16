import gleeunit
import gleeunit/should

import connect_4.{Game}
import connect_4 as c

pub fn main() {
  gleeunit.main()
}

pub fn update_turn_test() {
  c.update_turn
}
