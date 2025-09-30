defmodule Sharvit.Transpiler.Operators do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @accepted_binary_operators [:+, :-, :*, :/, :==, :===]

  @spec transpile_operator(
          ir :: IR.ConsOperator.t() | IR.MatchOperator.t() | IR.LocalFunctionCall.t()
        ) ::
          ESTree.operator() | ESTree.Node.t()
  def transpile_operator(ir)

  def transpile_operator(%IR.LocalFunctionCall{function: binary_operator, args: [left, right]})
      when binary_operator in @accepted_binary_operators do
    Builder.binary_expression(
      binary_operator,
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right)
    )
  end

  def transpile_operator(%IR.LocalFunctionCall{function: :|>, args: [left, right]}) do
    right
    |> Map.get_and_update!(:args, &{&1, List.insert_at(&1, 0, left)})
    |> elem(1)
    |> Transpiler.transpile_hologram_ir!()
  end

  # TODO: fix for nested cons (for ex. [1, 2 | [3]])
  def transpile_operator(%IR.ConsOperator{head: head, tail: rest}) do
    Builder.array_pattern([
      Transpiler.transpile_hologram_ir!(head),
      Builder.rest_element(Transpiler.transpile_hologram_ir!(rest))
    ])
  end

  # SPECIAL CASE - use var!/1 to declare variables
  def transpile_operator(%IR.MatchOperator{
        left: %IR.LocalFunctionCall{function: :var!, args: [%IR.Variable{name: var_name}]},
        right: init_value
      }) do
    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          Builder.identifier(var_name),
          Transpiler.transpile_hologram_ir!(init_value)
        )
      ],
      :let
    )
  end

  # TODO: make this work (pattern cant be given to var!/1)
  def transpile_operator(%IR.MatchOperator{
        left: %IR.LocalFunctionCall{function: :var!, args: [pattern_ir]},
        right: init_value
      }) do
    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          Transpiler.Patterns.transpile_and_sterilize_pattern(pattern_ir, :constants),
          Transpiler.Patterns.transpile_as_pattern_verify(pattern_ir, init_value)
        )
      ],
      :let
    )
  end

  def transpile_operator(%IR.MatchOperator{left: left, right: right}) do
    Builder.assignment_expression(
      :=,
      Transpiler.Patterns.transpile_and_sterilize_pattern(left, :constants),
      Transpiler.Patterns.transpile_as_pattern_verify(left, right)
    )
  end
end
