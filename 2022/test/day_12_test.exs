defmodule Day12Test do
  @moduledoc """
  Tests for Day 12 of Advent of Code 2022.
  """
  use ExUnit.Case
  doctest Day12

  @puzzle_input File.read!("priv/12.txt")

  @sample_input """
  """

  test "part 1 example" do
    assert Day12.part_one(@sample_input) == :ok
  end

  @tag :skip
  test "part 1 solution" do
    assert Day12.part_one(@puzzle_input) == :ok
  end

  @tag :skip
  test "part 2 example" do
    assert Day12.part_two(@sample_input) == :ok
  end

  @tag :skip
  test "part 2 solution" do
    assert Day12.part_two(@puzzle_input) == :ok
  end
end
