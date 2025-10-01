defmodule Sharvit.Transpiler.Patterns do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  # TODO: add cons + pin operators
  @type patternable ::
          IR.Variable.t()
          | IR.AtomType.t()
          | IR.StringType.t()
          | IR.IntegerType.t()
          | IR.FloatType.t()
          | IR.ListType.t()
          | IR.MapType.t()
          | IR.TupleType.t()
          | IR.MatchPlaceholder.t()

  @spec transpile_pattern(ir :: IR.MatchPlaceholder.t()) :: ESTree.Node.t() | ESTree.operator()
  def transpile_pattern(ir)

  def transpile_pattern(%IR.MatchPlaceholder{}) do
    Builder.member_expression(Builder.identifier("sharvitPatterns"), Builder.identifier("any"))
  end

  @spec transpile_and_sterilize_pattern(ir :: patternable(), target :: :variables | :constants) ::
          ESTree.Node.t() | nil
  def transpile_and_sterilize_pattern(ir, target)

  def transpile_and_sterilize_pattern(%IR.Variable{} = ir, target) do
    if target == :variables,
      do: Transpiler.transpile_hologram_ir!(%IR.MatchPlaceholder{}),
      else: Transpiler.transpile_hologram_ir!(ir)
  end

  def transpile_and_sterilize_pattern(%ir_struct{} = ir, target)
      when ir_struct in [IR.AtomType, IR.StringType, IR.IntegerType, IR.FloatType] do
    if target == :constants, do: nil, else: Transpiler.transpile_hologram_ir!(ir)
  end

  def transpile_and_sterilize_pattern(%IR.MatchPlaceholder{} = ir, target) do
    if target == :constants, do: nil, else: Transpiler.transpile_hologram_ir!(ir)
  end

  def transpile_and_sterilize_pattern(%ir_struct{data: data}, target)
      when ir_struct in [IR.ListType, IR.TupleType] do
    data
    |> Enum.map(&transpile_and_sterilize_pattern(&1, target))
    |> Builder.array_expression()
  end

  def transpile_and_sterilize_pattern(%IR.MapType{data: data}, target) do
    map_data =
      if target == :variables,
        do: data,
        else: Enum.filter(data, &match?(%IR.Variable{}, elem(&1, 1)))

    map_data
    |> Enum.map(
      &Builder.property(
        Builder.array_expression([Transpiler.transpile_hologram_ir!(elem(&1, 0))]),
        transpile_and_sterilize_pattern(elem(&1, 1), target)
      )
    )
    |> Builder.object_expression()
  end

  @spec transpile_as_pattern_verify(pattern :: patternable(), value :: IR.t()) ::
          ESTree.CallExpression.t()
  def transpile_as_pattern_verify(pattern, value) do
    Builder.call_expression(Builder.identifier("verifyPatternMatch"), [
      transpile_and_sterilize_pattern(pattern, :variables),
      Transpiler.transpile_hologram_ir!(value)
    ])
  end
end
