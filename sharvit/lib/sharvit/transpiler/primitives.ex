defmodule Sharvit.Transpiler.Primitives do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_primitive(
          ir ::
            IR.StringType.t()
            | IR.BitstringType.t()
            | IR.BitstringSegment.t()
            | IR.AtomType.t()
            | IR.IntegerType.t()
            | IR.FloatType.t()
            | IR.Variable.t()
        ) :: ESTree.Node.t()
  def transpile_primitive(ir)

  def transpile_primitive(%IR.StringType{value: value}) do
    Builder.literal(value)
  end

  def transpile_primitive(%IR.AtomType{value: boolean_value})
      when boolean_value in [true, false] do
    Builder.literal(boolean_value == true)
  end

  def transpile_primitive(%IR.AtomType{value: nil}) do
    Builder.literal(nil)
  end

  def transpile_primitive(%IR.AtomType{value: value}) do
    # TODO: make module names not symbols?
    Builder.member_expression(Builder.identifier("Symbol"), Builder.identifier("for"))
    |> Builder.call_expression([Builder.literal(value)])
  end

  def transpile_primitive(%IR.IntegerType{value: value}) do
    Builder.literal(value)
  end

  def transpile_primitive(%IR.FloatType{value: value}) do
    Builder.literal(value)
  end

  def transpile_primitive(%IR.Variable{name: name, version: nil}) do
    Builder.identifier(escape_identifier(name))
  end

  def transpile_primitive(%IR.Variable{name: name, version: version}) do
    Builder.identifier(escape_identifier(name) <> "$V#{version}")
  end

  def transpile_primitive(%IR.BitstringType{segments: [segment]}) do
    transpile_primitive(segment)
  end

  def transpile_primitive(%IR.BitstringType{segments: [first_segment | rest]}) do
    transpile_primitive(first_segment)
    |> Builder.member_expression(Builder.identifier("concat"))
    |> Builder.call_expression(Enum.map(rest, &transpile_primitive/1))
  end

  def transpile_primitive(%IR.BitstringSegment{value: value}) do
    Transpiler.transpile_hologram_ir!(value)
  end

  @spec escape_identifier(identifier :: String.t() | atom()) :: String.t()
  def escape_identifier(identifier)

  def escape_identifier(identifier) when is_atom(identifier),
    do: escape_identifier(Atom.to_string(identifier))

  def escape_identifier(identifier) do
    String.replace(identifier, ~r/[\?!]/, fn
      "?" -> "$Q$"
      "!" -> "$B$"
    end)
  end
end
