defmodule Sharvit.Transpiler.Primitives do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR

  @spec transpile_primitive(
          ir :: IR.StringType.t() | IR.AtomType.t() | IR.IntegerType.t() | IR.FloatType.t()
        ) :: ESTree.Node.t() | ESTree.operator()
  def transpile_primitive(ir)

  def transpile_primitive(%IR.StringType{value: value}) do
    Builder.literal(value)
  end

  def transpile_primitive(%IR.AtomType{value: value}) do
    #  TODO: make module names not symbols
    Builder.member_expression(Builder.identifier("Symbol"), Builder.identifier("for"))
    |> Builder.call_expression([Builder.literal(value)])
  end

  def transpile_primitive(%IR.IntegerType{value: value}) do
    Builder.literal(value)
  end

  def transpile_primitive(%IR.FloatType{value: value}) do
    Builder.literal(value)
  end
end
