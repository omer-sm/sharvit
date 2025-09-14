defmodule Sharvit.Transpiler.ControlFlow do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_control_flow(ir :: IR.Block.t() | IR.LocalFunctionCall.t()) ::
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

  @doc """
  Given a list of expression IRs or a single expression IR, will transpile it and
  make the last expression a return statement.
  Given a block IR, it will return an equivalent ESTree block with the last expression
  in the block as the return value.
  """
  @spec transpile_expressions_and_return_last(expression_ir :: IR.t() | list(IR.t())) ::
          ESTree.Node.t()
  def transpile_expressions_and_return_last(expression_ir)

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
  @spec wrap_in_iife(statement :: ESTree.Node.t()) :: ESTree.ExpressionStatement.t()
  def wrap_in_iife(statement)

  def wrap_in_iife(%ESTree.BlockStatement{} = statement) do
    Builder.function_expression([], [], statement)
    |> Builder.call_expression([])
    |> Builder.expression_statement()
  end

  def wrap_in_iife(statement) do
    iife_body = Builder.block_statement([statement])

    Builder.function_expression([], [], iife_body)
    |> Builder.call_expression([])
    |> Builder.expression_statement()
  end
end
