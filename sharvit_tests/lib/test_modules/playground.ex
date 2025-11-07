defmodule SharvitTests.TestModules.Playground do
  def t() do
    case {} do
      {_, _} = tuple -> tuple
      tuple = {_, _} -> tuple
    end
  end
end
