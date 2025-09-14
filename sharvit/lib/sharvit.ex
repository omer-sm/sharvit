defmodule Sharvit do
  alias ESTree.Tools.Generator
  alias Hologram.Compiler.IR
  alias Hologram.Compiler.Context
  alias Sharvit.Transpiler

  @doc """
  Transpiles a string containing Elixir code into equivalent JS code.
  """
  @spec transpile_code!(code :: String.t()) :: String.t()
  def transpile_code!(code) do
    IR.for_code(code, %Context{})
    |> IO.inspect()
    |> Transpiler.transpile_hologram_ir!()
    |> Generator.generate()
  end

  @doc """
  Transpiles an Elixir module into an equivalent JS class.
  """
  @spec transpile_module!(module :: module()) :: String.t()
  def transpile_module!(module) do
    IR.for_module(module)
    |> Transpiler.transpile_hologram_ir!()
    |> Generator.generate()
  end
end
