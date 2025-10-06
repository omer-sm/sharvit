defmodule Sharvit do
  alias ESTree.Tools.Generator
  alias Hologram.Compiler.IR
  alias Hologram.Compiler.Context
  alias Sharvit.Transpiler

  @doc """
  Transpiles a list of Elixir modules into a JS program containing the modules
  and Sharvit's runtime code.
  """
  @spec transpile_program!(modules :: list(module())) :: String.t()
  def transpile_program!(modules) do
    Sharvit.Js.get_sharvit_js_code!() <>
      "\n\n" <>
      Enum.map_join(modules, "\n\n", &transpile_module!/1)
  end

  @doc """
  Transpiles a string containing Elixir code into equivalent JS code.
  """
  @spec transpile_code!(code :: String.t()) :: String.t()
  def transpile_code!(code) do
    Sharvit.Config.put_config_value(:code_mode, :uncompiled)

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
    Sharvit.Config.put_config_value(:code_mode, :compiled)

    IR.for_module(module)
    |> tap(&(
      if Sharvit.Config.ir_debug_mode() do
        {:ok, file} = File.open("out/#{inspect(module)}_ir.txt", [:write])
        IO.inspect(file, &1, label: "#{inspect(module)}")
      end
    ))
    |> Transpiler.transpile_hologram_ir!()
    |> Generator.generate()
  end

  @doc """
  Used when declaring variables in uncompiled code.
  Will return the argument given to it.
  Note that reassigning variables is not recommended as scopes currently
  behave differently than they do in Elixir.

  Note: For compiled code this is unnecessary.

  ## Example Usage
  ```
  # Instead of this:
  [a, b] = [1, 2]
  a = a + 1

  # Do this:
  [a, b] = Sharvit.declare([1, 2])
  a = a + 1 # Reassignment is done normally
  a_1 = Sharvit.declare(a + 1) # However, this is a better practice
  ``
  """
  @spec declare(value :: term()) :: term()
  def declare(value), do: value
end
