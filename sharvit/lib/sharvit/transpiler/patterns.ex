defmodule Sharvit.Transpiler.Patterns do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @type patternable ::
          IR.Variable.t()
          | IR.AtomType.t()
          | IR.StringType.t()
          | IR.IntegerType.t()
          | IR.FloatType.t()
          | IR.ListType.t()
          | IR.MapType.t()
          | IR.ConsOperator.t()
          | IR.TupleType.t()
          | IR.MatchPlaceholder.t()
          | IR.MatchOperator.t()
          | IR.PinOperator.t()

  @spec transpile_pattern(ir :: IR.MatchPlaceholder.t()) :: ESTree.Node.t()
  def transpile_pattern(ir)

  def transpile_pattern(%IR.MatchPlaceholder{}) do
    get_js_pattern(:any)
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
        else:
          Enum.filter(
            data,
            &(match?(%IR.Variable{}, elem(&1, 1)) || match?(%IR.MatchOperator{}, elem(&1, 1)))
          )

    map_data
    |> Enum.map(
      &Builder.property(
        Transpiler.transpile_hologram_ir!(elem(&1, 0)),
        transpile_and_sterilize_pattern(elem(&1, 1), target),
        :init,
        false,
        false,
        true
      )
    )
    |> Builder.object_expression()
  end

  def transpile_and_sterilize_pattern(%IR.PinOperator{variable: variable}, target) do
    if target == :constants, do: nil, else: Transpiler.transpile_hologram_ir!(variable)
  end

  def transpile_and_sterilize_pattern(%IR.ConsOperator{} = cons_ir, target) do
    Builder.array_pattern(
      Transpiler.Operators.transpile_and_flatten_cons(cons_ir, {:pattern, target})
    )
  end

  def transpile_and_sterilize_pattern(%IR.MatchOperator{left: left, right: %IR.Variable{} = right}, target) do
    if target == :constants,
      do: %ESTree.AssignmentPattern{
        left: Transpiler.transpile_hologram_ir!(right),
        right: Transpiler.transpile_hologram_ir!(left)
      },
      else: Transpiler.transpile_hologram_ir!(left)
  end

  # TODO: check if correct for variables
  def transpile_and_sterilize_pattern(%IR.MatchOperator{left: left, right: right}, target) do
    if target == :constants,
      do: %ESTree.AssignmentPattern{
        left: Transpiler.transpile_hologram_ir!(left),
        right: Transpiler.transpile_hologram_ir!(right)
      },
      else: Transpiler.transpile_hologram_ir!(right)
  end

  @spec transpile_as_pattern_verify(pattern :: patternable(), value :: IR.t()) ::
          ESTree.CallExpression.t()
  def transpile_as_pattern_verify(pattern, value) do
    Builder.call_expression(Builder.identifier("verifyPatternMatch"), [
      transpile_and_sterilize_pattern(pattern, :variables),
      Transpiler.transpile_hologram_ir!(value)
    ])
  end

  @spec get_js_pattern(pattern_name :: :any | :any_or_missing | :cons_tail) ::
          ESTree.MemberExpression.t()
  def get_js_pattern(pattern_name),
    do:
      Builder.member_expression(
        Builder.identifier("sharvitPatterns"),
        Builder.identifier(Atom.to_string(pattern_name))
      )
end
