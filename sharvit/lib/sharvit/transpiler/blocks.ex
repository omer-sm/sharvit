defmodule Sharvit.Transpiler.Blocks do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_block(
          ir ::
            IR.Block.t()
        ) ::
          ESTree.BlockStatement.t()
  def transpile_block(%IR.Block{expressions: expressions}) do
    expressions
    |> Enum.flat_map(&(collect_extras(&1) ++ [Transpiler.transpile_hologram_ir!(&1)]))
    |> Enum.map(fn
      %ESTree.VariableDeclarator{} = ir -> Builder.variable_declaration([ir], :const)
      other -> other
    end)
    |> Builder.block_statement()
  end

  # TODO: cons, dot op, match for patterns
  @spec collect_extras(ir :: IR.t()) ::
          extra_statements :: list(ESTree.VariableDeclarator.t())

  def collect_extras(ir)

  def collect_extras(%IR.MatchOperator{left: %IR.Variable{} = left, right: right}) do
    collect_extras(right) ++
      [
        Builder.variable_declarator(
          Transpiler.Primitives.transpile_primitive(left),
          Transpiler.transpile_hologram_ir!(right)
        )
      ]
  end

  def collect_extras(%IR.MatchOperator{left: left, right: right}) do
    collect_extras(right) ++
      [
        Builder.variable_declarator(
          Transpiler.Patterns.transpile_and_sterilize_pattern(left, :constants),
          Transpiler.Patterns.transpile_as_pattern_verify(left, right)
        )
      ]
  end

  def collect_extras(%IR.LocalFunctionCall{args: args}) do
    collect_extras_in_list(args)
  end

  def collect_extras(%IR.RemoteFunctionCall{args: args}) do
    collect_extras_in_list(args)
  end

  def collect_extras(%IR.AnonymousFunctionCall{args: args}) do
    collect_extras_in_list(args)
  end

  def collect_extras(%IR.MapType{data: data}) do
    Enum.flat_map(data, fn {key_ir, value_ir} ->
      collect_extras(key_ir) ++ collect_extras(value_ir)
    end)
  end

  def collect_extras(%IR.ListType{data: data}) do
    collect_extras_in_list(data)
  end

  def collect_extras(%IR.TupleType{data: data}) do
    collect_extras_in_list(data)
  end

  def collect_extras(%IR.Case{condition: condition}) do
    collect_extras(condition)
  end

  def collect_extras(%IR.Cond{clauses: clauses}) do
    collect_extras_in_list(clauses)
  end

  def collect_extras(%IR.CondClause{condition: condition}) do
    collect_extras(condition)
  end

  def collect_extras(_), do: []

  @doc """
  Given a list of expression IRs or a single expression IR, will transpile it and
  make the last (/only) expression a return statement.
  Given a block IR, it will return an equivalent ESTree block with the last expression
  in the block as the return value.
  Given an empty list, it will return a "return undefined" statement.
  """
  @spec transpile_expressions_and_return_last(expression_ir :: IR.t() | list(IR.t())) ::
          ESTree.BlockStatement.t() | ESTree.ReturnStatement.t()
  def transpile_expressions_and_return_last(expression_ir)

  def transpile_expressions_and_return_last(%IR.Block{} = block_ir) do
    expressions_transpiled = transpile_block(block_ir).body
    last_expression = List.last(expressions_transpiled)

    if(Transpiler.ControlFlow.is_returnable?(last_expression)) do
      return_statement = Builder.return_statement(last_expression)

      List.replace_at(
        expressions_transpiled,
        length(expressions_transpiled) - 1,
        return_statement
      )
    else
      return_statement = Builder.return_statement(Builder.literal(nil))
      expressions_transpiled ++ [return_statement]
    end
    |> Builder.block_statement()
  end

  def transpile_expressions_and_return_last([]),
    do: Builder.return_statement(Builder.identifier("undefined"))

  def transpile_expressions_and_return_last(expression_ir) when is_list(expression_ir) do
    transpile_expressions_and_return_last(%IR.Block{expressions: expression_ir})
  end

  def transpile_expressions_and_return_last(expression_ir) do
    transpile_expressions_and_return_last(%IR.Block{expressions: [expression_ir]})
  end

  defp collect_extras_in_list(ir_list) do
    Enum.flat_map(ir_list, &collect_extras/1)
  end
end
