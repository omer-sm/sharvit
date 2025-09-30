defmodule Sharvit.Transpiler.Collectables do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_collectable(ir :: IR.MapType.t() | IR.ListType.t() | IR.TupleType.t()) ::
          ESTree.operator() | ESTree.Node.t()
  def transpile_collectable(ir)

  def transpile_collectable(%IR.MapType{data: data}) do
    Builder.object_expression(
      Enum.map(data, fn {key, val} ->
        Builder.property(
          Builder.array_expression([
            Transpiler.transpile_hologram_ir!(key)
          ]),
          Transpiler.transpile_hologram_ir!(val)
        )
      end)
    )
  end

  def transpile_collectable(%IR.ListType{data: data}) do
    Builder.array_expression(Enum.map(data, &Transpiler.transpile_hologram_ir!/1))
  end

  def transpile_collectable(%IR.TupleType{data: data}) do
    Builder.array_expression(Enum.map(data, &Transpiler.transpile_hologram_ir!/1))
  end
end
