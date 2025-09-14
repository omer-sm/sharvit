defmodule SharvitTest do
  use ExUnit.Case
  doctest Sharvit

  test "greets the world" do
    assert Sharvit.hello() == :world
  end
end
