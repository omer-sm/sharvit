defmodule SharvitTests.TestModules.ProgramTest do
  @my_attribute 1

  @doc false
  def my_func() do
    [:+, :-, :*, :/, :==, :===, :|>]
    1 + 1
    1 - 1
    1 * 1
    1 / 1

    if (1 != 1) do

    end

    if (1 !== 1) do

    end

    {1, 2}
    |> elem(1)
  end

  def my_func(arg) do
    @my_attribute
  end
end
