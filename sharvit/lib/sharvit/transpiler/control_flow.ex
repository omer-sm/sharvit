defmodule Sharvit.Transpiler.ControlFlow do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_control_flow(
          ir ::
            IR.Block.t() | IR.LocalFunctionCall.t() | IR.Clause.t() | IR.Case.t() | IR.Cond.t()
        ) ::
          ESTree.operator() | ESTree.Node.t()
  def transpile_control_flow(ir)

  def transpile_control_flow(%IR.Block{expressions: expressions}) do
    expressions
    |> Enum.map(&Transpiler.transpile_hologram_ir!/1)
    |> Builder.block_statement()
  end

  def transpile_control_flow(%IR.LocalFunctionCall{
        function: :if,
        args: [test_expression, %IR.ListType{data: whole_body_data}]
      }) do
    {do_block, else_block} =
      case whole_body_data do
        [%IR.TupleType{data: [%IR.AtomType{value: :do}, body_ir]}] ->
          {transpile_expressions_and_return_last(body_ir), nil}

        [
          %IR.TupleType{
            data: [%IR.AtomType{value: :do}, body_ir]
          },
          %IR.TupleType{
            data: [%IR.AtomType{value: :else}, else_ir]
          }
        ] ->
          {transpile_expressions_and_return_last(body_ir),
           transpile_expressions_and_return_last(else_ir)}
      end

    Builder.if_statement(Transpiler.transpile_hologram_ir!(test_expression), do_block, else_block)
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
    clause_body = transpile_expressions_and_return_last(body)

    Builder.if_statement(
      Transpiler.transpile_hologram_ir!(condition),
      clause_body,
      transpile_cond_clauses([next_clause | rest])
    )
  end

  def transpile_cond_clauses([%IR.CondClause{condition: condition, body: body}]) do
    clause_body = transpile_expressions_and_return_last(body)
    Builder.if_statement(Transpiler.transpile_hologram_ir!(condition), clause_body)
  end

  @doc """
  Given a list of expression IRs or a single expression IR, will transpile it and
  make the last (/only) expression a return statement.
  Given a block IR, it will return an equivalent ESTree block with the last expression
  in the block as the return value.
  Given an empty list, it will return a "return undefined" statement.
  """
  @spec transpile_expressions_and_return_last(expression_ir :: IR.t() | list(IR.t())) ::
          ESTree.Node.t()
  def transpile_expressions_and_return_last(expression_ir)

  def transpile_expressions_and_return_last([]),
    do: Builder.return_statement(Builder.identifier("undefined"))

  def transpile_expressions_and_return_last(%IR.Block{expressions: expressions}) do
    expressions_transpiled = Enum.map(expressions, &Transpiler.transpile_hologram_ir!/1)
    return_statement = Builder.return_statement(List.last(expressions_transpiled))

    List.replace_at(expressions_transpiled, length(expressions_transpiled) - 1, return_statement)
    |> Builder.block_statement()
  end

  def transpile_expressions_and_return_last(expression_ir) when is_list(expression_ir) do
    expressions_transpiled = Enum.map(expression_ir, &Transpiler.transpile_hologram_ir!/1)
    return_statement = Builder.return_statement(List.last(expressions_transpiled))

    List.replace_at(expressions_transpiled, length(expressions_transpiled) - 1, return_statement)
    |> Builder.block_statement()
  end

  def transpile_expressions_and_return_last(expression_ir) do
    expression_ir
    |> Transpiler.transpile_hologram_ir!()
    |> Builder.return_statement()
  end

  @doc """
  Wraps an ESTree statement in an IIFE.
  """
  @spec wrap_in_iife(statement :: ESTree.Node.t(), arguments :: list(ESTree.Node.t())) :: ESTree.ExpressionStatement.t()
  def wrap_in_iife(statement, arguments \\ [])

  def wrap_in_iife(%ESTree.BlockStatement{} = statement, arguments) do
    Builder.function_expression([], [], statement)
    |> Builder.call_expression(arguments)
    |> Builder.expression_statement()
  end

  def wrap_in_iife(statement, arguments) do
    wrap_in_iife(Builder.block_statement([statement]), arguments)
  end
end
