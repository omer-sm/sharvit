defmodule SharvitTests.TestModules.LeetcodeSolution do
  # https://leetcode.com/problems/water-bottles-ii

  @spec max_bottles_drunk(num_bottles :: integer, num_exchange :: integer) :: integer
  def max_bottles_drunk(num_bottles, num_exchange)

  def max_bottles_drunk(num_bottles, num_exchange) when num_bottles < num_exchange,
    do: num_bottles

  def max_bottles_drunk(num_bottles, num_exchange),
    do: max_bottles_drunk(num_bottles - num_exchange + 1, num_exchange + 1) + num_exchange
end
