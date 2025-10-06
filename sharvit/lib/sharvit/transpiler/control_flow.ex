defmodule Sharvit.Transpiler.ControlFlow do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_control_flow(
          ir ::
            IR.LocalFunctionCall.t() | IR.Clause.t() | IR.Case.t() | IR.Cond.t()
        ) ::
          ESTree.operator() | ESTree.Node.t()
  def transpile_control_flow(ir)

  def transpile_control_flow(%IR.LocalFunctionCall{
        function: :if,
        args: [test_expression, %IR.ListType{data: whole_body_data}]
      }) do
    {do_block, else_block} =
      case whole_body_data do
        [%IR.TupleType{data: [%IR.AtomType{value: :do}, body_ir]}] ->
          {Transpiler.Blocks.transpile_expressions_and_return_last(body_ir), nil}

        [
          %IR.TupleType{
            data: [%IR.AtomType{value: :do}, body_ir]
          },
          %IR.TupleType{
            data: [%IR.AtomType{value: :else}, else_ir]
          }
        ] ->
          {Transpiler.Blocks.transpile_expressions_and_return_last(body_ir),
           Transpiler.Blocks.transpile_expressions_and_return_last(else_ir)}
      end

    Builder.if_statement(Transpiler.transpile_hologram_ir!(test_expression), do_block, else_block)
    |> wrap_in_iife()
  end

  # Match compiled if statements
  def transpile_control_flow(%IR.Case{
        condition: test_expression,
        clauses: [
          %IR.Clause{
            match: %IR.AtomType{value: false},
            guards: [],
            body: do_block_ir
          },
          %Hologram.Compiler.IR.Clause{
            match: %Hologram.Compiler.IR.AtomType{value: true},
            guards: [],
            body: else_block_ir
          }
        ]
      }) do
    do_block_transpiled = Transpiler.Blocks.transpile_expressions_and_return_last(do_block_ir)
    else_block_transpiled = Transpiler.Blocks.transpile_expressions_and_return_last(else_block_ir)

    Builder.if_statement(
      Transpiler.transpile_hologram_ir!(test_expression),
      do_block_transpiled,
      else_block_transpiled
    )
    |> wrap_in_iife()
  end

  def transpile_control_flow(%IR.Case{condition: condition, clauses: clauses}) do
    clauses
    |> Enum.map(&Transpiler.transpile_hologram_ir!/1)
    |> Builder.block_statement()
    |> wrap_in_iife([Transpiler.transpile_hologram_ir!(condition)])
  end

  def transpile_control_flow(%IR.Clause{} = clause_ir) do
    clause_ir
    |> Transpiler.Clause.to_clause()
    |> Transpiler.Clause.transpile_clause()
  end

  def transpile_control_flow(%IR.Cond{clauses: clauses}) do
    transpile_cond_clauses(clauses)
    |> wrap_in_iife()
  end

  @spec transpile_cond_clauses(clauses :: list(IR.CondClause.t())) :: %ESTree.IfStatement{}
  def transpile_cond_clauses(clauses)

  def transpile_cond_clauses([
        %IR.CondClause{condition: condition, body: body},
        next_clause | rest
      ]) do
    clause_body = Transpiler.Blocks.transpile_expressions_and_return_last(body)

    Builder.if_statement(
      Transpiler.transpile_hologram_ir!(condition),
      clause_body,
      transpile_cond_clauses([next_clause | rest])
    )
  end

  def transpile_cond_clauses([%IR.CondClause{condition: condition, body: body}]) do
    clause_body = Transpiler.Blocks.transpile_expressions_and_return_last(body)
    Builder.if_statement(Transpiler.transpile_hologram_ir!(condition), clause_body)
  end

  @doc """
  Wraps an ESTree statement in an IIFE.
  """
  @spec wrap_in_iife(statement :: ESTree.Node.t(), arguments :: list(ESTree.Node.t())) ::
          ESTree.CallExpression.t()
  def wrap_in_iife(statement, arguments \\ [])

  def wrap_in_iife(%ESTree.BlockStatement{} = statement, arguments) do
    Builder.function_expression([], [], statement)
    |> Builder.call_expression(arguments)
  end

  def wrap_in_iife(statement, arguments) do
    wrap_in_iife(Builder.block_statement([statement]), arguments)
  end

  @spec is_returnable?(es_node :: ESTree.Node.t()) :: boolean()
  def is_returnable?(es_node)

  def is_returnable?(%node_struct{}),
    do:
      node_struct in [
        ESTree.ArrayExpression,
        ESTree.ArrayPattern,
        ESTree.ArrowFunctionExpression,
        ESTree.AwaitExpression,
        ESTree.BinaryExpression,
        ESTree.CallExpression,
        ESTree.ClassExpression,
        ESTree.EmptyExpression,
        ESTree.FunctionExpression,
        ESTree.Identifier,
        ESTree.LogicalExpression,
        ESTree.Literal,
        ESTree.MemberExpression,
        ESTree.NewExpression,
        ESTree.ObjectExpression,
        ESTree.ObjectPattern,
        ESTree.TemplateLiteral,
        ESTree.ThisExpression,
        ESTree.UnaryExpression,
        ESTree.YieldExpression
      ]
end
