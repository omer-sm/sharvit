defmodule Sharvit.Transpiler.Operators do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler
  alias Sharvit.Config

  @accepted_binary_operators [:+, :-, :*, :/, :==, :===, :"=:=", :>=, :<=, :<, :>, :"/=", :"=/="]
  @comparison_operators [:<=, :>=, :<, :>, :===, :==]

  # TODO: make it not use compare() for literals?
  @spec transpile_operator(
          ir ::
            IR.ConsOperator.t()
            | IR.MatchOperator.t()
            | IR.DotOperator.t()
            | IR.LocalFunctionCall.t()
            | IR.RemoteFunctionCall.t()
            | IR.PinOperator.t()
        ) ::
          ESTree.Node.t()
  def transpile_operator(ir)

  def transpile_operator(%IR.LocalFunctionCall{function: :==, args: [left, right]}) do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      :===
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: :"=:=", args: [left, right]}) do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      :===
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: :"=/=", args: [left, right]}) do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      :!==
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: :"/=", args: [left, right]}) do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      :!==
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: :==, args: [left, right]}) do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      :===
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: binary_operator, args: [left, right]})
      when binary_operator in @comparison_operators do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      binary_operator
    )
  end

  def transpile_operator(%IR.LocalFunctionCall{function: binary_operator, args: [left, right]})
      when binary_operator in @comparison_operators do
    get_comparison_call(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      binary_operator
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{function: binary_operator, args: [left, right]})
      when binary_operator in @accepted_binary_operators do
    Builder.binary_expression(
      binary_operator,
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right)
    )
  end

  def transpile_operator(%IR.RemoteFunctionCall{
        module: %IR.AtomType{value: :erlang},
        function: :orelse,
        args: [left, right]
      }) do
    Builder.binary_expression(
      :||,
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right)
    )
  end

  def transpile_operator(%IR.LocalFunctionCall{function: binary_operator, args: [left, right]})
      when binary_operator in @accepted_binary_operators do
    Builder.binary_expression(
      binary_operator,
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right)
    )
  end

  # For uncompiled pipes
  def transpile_operator(%IR.LocalFunctionCall{function: :|>, args: [left, right]}) do
    right
    |> Map.get_and_update!(:args, &{&1, List.insert_at(&1, 0, left)})
    |> elem(1)
    |> Transpiler.transpile_hologram_ir!()
  end

  def transpile_operator(%IR.ConsOperator{} = cons_ir) do
    Builder.array_expression(transpile_and_flatten_cons(cons_ir, :expression))
  end

  # Variable assignments with explicit declaration
  def transpile_operator(%IR.MatchOperator{
        left: %IR.Variable{} = left,
        right: %IR.RemoteFunctionCall{
          function: :declare,
          module: %IR.AtomType{value: :Elixir_Sharvit},
          args: [init_value]
        }
      }) do
    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          Transpiler.transpile_hologram_ir!(left),
          Transpiler.transpile_hologram_ir!(init_value)
        )
      ],
      if(Config.code_mode() == :compiled, do: :const, else: :let)
    )
  end

  # Pattern match assignments with explicit declaration
  def transpile_operator(%IR.MatchOperator{
        left: left,
        right: %IR.RemoteFunctionCall{
          function: :declare,
          module: %IR.AtomType{value: :Elixir_Sharvit},
          args: [init_value]
        }
      }) do
    if match?(%IR.PinOperator{}, left) do
      raise "Pin operator cannot be used with Sharvit.declare/1"
    end

    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          Transpiler.Patterns.transpile_and_sterilize_pattern(left, :constants),
          Transpiler.Patterns.transpile_as_pattern_verify(left, init_value)
        )
      ],
      if(Config.code_mode() == :compiled, do: :const, else: :let)
    )
  end

  # Variable assignments without explicit declaration
  def transpile_operator(%IR.MatchOperator{
        left: %IR.Variable{} = left,
        right: right
      }) do
    if Config.code_mode() == :uncompiled do
      Builder.assignment_expression(
        :=,
        Transpiler.transpile_hologram_ir!(left),
        Transpiler.transpile_hologram_ir!(right)
      )
    else
      Transpiler.transpile_hologram_ir!(left)
    end
  end

  # Pin operator matches
  def transpile_operator(%IR.MatchOperator{
        left: %IR.PinOperator{} = left,
        right: right
      }) do
    Transpiler.Patterns.transpile_as_pattern_verify(left, right)
  end

  # Pattern match assignments without explicit declaration
  def transpile_operator(%IR.MatchOperator{
        left: left,
        right: right
      }) do
    if Config.code_mode() == :uncompiled do
      Builder.assignment_expression(
        :=,
        Transpiler.Patterns.transpile_and_sterilize_pattern(left, :constants),
        Transpiler.Patterns.transpile_as_pattern_verify(left, right)
      )
    else
      Transpiler.Patterns.transpile_and_sterilize_pattern(left, :constants)
    end
  end

  def transpile_operator(%IR.DotOperator{left: left, right: right}) do
    Builder.member_expression(
      Transpiler.transpile_hologram_ir!(left),
      Transpiler.transpile_hologram_ir!(right),
      true
    )
  end

  # For map keys
  def transpile_operator(%IR.PinOperator{variable: pinned_variable}) do
    Transpiler.transpile_hologram_ir!(pinned_variable)
  end

  @spec transpile_and_flatten_cons(
          cons_ir :: IR.ConsOperator.t(),
          type :: :expression | {:pattern, :variables | :constants}
        ) ::
          list(ESTree.Node.t())
  def transpile_and_flatten_cons(cons_ir, type)

  # [1 | [2, 3]]
  def transpile_and_flatten_cons(
        %IR.ConsOperator{
          head: head,
          tail: %IR.ListType{data: tail_data}
        },
        :expression
      ) do
    [
      Transpiler.transpile_hologram_ir!(head)
      | Enum.map(tail_data, &Transpiler.transpile_hologram_ir!/1)
    ]
  end

  def transpile_and_flatten_cons(
        %IR.ConsOperator{
          head: head,
          tail: %IR.ListType{data: tail_data}
        },
        {:pattern, pattern_target}
      ) do
    [
      Transpiler.Patterns.transpile_and_sterilize_pattern(head, pattern_target)
      | Enum.map(
          tail_data,
          &Transpiler.Patterns.transpile_and_sterilize_pattern(&1, pattern_target)
        )
    ]
  end

  # [1 | [2 | [3]]] / [1, 2 | [3]]
  def transpile_and_flatten_cons(
        %IR.ConsOperator{head: head, tail: %IR.ConsOperator{} = tail},
        :expression
      ) do
    [Transpiler.transpile_hologram_ir!(head) | transpile_and_flatten_cons(tail, :expression)]
  end

  def transpile_and_flatten_cons(
        %IR.ConsOperator{head: head, tail: %IR.ConsOperator{} = tail},
        {:pattern, pattern_target}
      ) do
    [
      Transpiler.Patterns.transpile_and_sterilize_pattern(head, pattern_target)
      | transpile_and_flatten_cons(tail, {:pattern, pattern_target})
    ]
  end

  # [1 | func()]
  def transpile_and_flatten_cons(%IR.ConsOperator{head: head, tail: tail}, :expression) do
    [
      Transpiler.transpile_hologram_ir!(head),
      Builder.spread_element(Transpiler.transpile_hologram_ir!(tail))
    ]
  end

  def transpile_and_flatten_cons(
        %IR.ConsOperator{head: head, tail: %tail_struct{}},
        {:pattern, :variables}
      )
      when tail_struct in [IR.Variable, IR.MatchPlaceholder] do
    [
      Transpiler.Patterns.transpile_and_sterilize_pattern(head, :variables),
      Transpiler.Patterns.get_js_pattern(:cons_tail)
    ]
  end

  def transpile_and_flatten_cons(
        %IR.ConsOperator{head: head, tail: tail},
        {:pattern, pattern_target}
      ) do
    [
      Transpiler.Patterns.transpile_and_sterilize_pattern(head, pattern_target),
      Builder.rest_element(
        Transpiler.Patterns.transpile_and_sterilize_pattern(tail, pattern_target) ||
          Builder.array_expression([])
      )
    ]
  end

  @spec get_comparison_call(
          left :: ESTree.Node.t(),
          right :: ESTree.Node.t(),
          js_operator :: ESTree.binary_operator()
        ) :: ESTree.BinaryExpression.t()
  def get_comparison_call(left, right, js_operator) do
    Builder.binary_expression(
      js_operator,
      Builder.call_expression(
        Builder.identifier("compare"),
        [left, right]
      ),
      Builder.literal(0)
    )
  end
end
