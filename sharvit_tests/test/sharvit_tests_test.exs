defmodule SharvitTestsTest do
  use ExUnit.Case
  doctest SharvitTests

  test "greets the world" do
    assert SharvitTests.hello() == :world
  end
end
