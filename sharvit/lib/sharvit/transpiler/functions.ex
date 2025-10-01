defmodule Sharvit.Transpiler.Functions do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_function_call(ir :: IR.LocalFunctionCall.t() | IR.RemoteFunctionCall.t()) ::
          ESTree.operator() | ESTree.Node.t()
  def transpile_function_call(ir)

  def transpile_function_call(%IR.LocalFunctionCall{function: function_name, args: args}) do
    Builder.identifier(Atom.to_string(function_name))
    |> Builder.call_expression(Enum.map(args, &Transpiler.transpile_hologram_ir!/1))
  end

  def transpile_function_call(%IR.RemoteFunctionCall{
        module: %IR.AtomType{value: module_name},
        function: function_name,
        args: args
      }) do
    callee_object = Builder.identifier(Atom.to_string(module_name))
    callee_property = Builder.identifier(Atom.to_string(function_name))
    callee = Builder.member_expression(callee_object, callee_property)

    Builder.call_expression(callee, Enum.map(args, &Transpiler.transpile_hologram_ir!/1))
  end

  @spec transpile_function_clause(ir :: IR.FunctionClause.t()) :: ESTree.IfStatement.t()
  def transpile_function_clause(%IR.FunctionClause{} = clause_ir) do
    clause_ir
    |> Transpiler.Clause.to_clause()
    |> Transpiler.Clause.transpile_clause()
  end

  @spec transpile_anonymous_function(ir :: IR.AnonymousFunctionType.t()) ::
          ESTree.FunctionExpression.t()

  def transpile_anonymous_function(%IR.AnonymousFunctionType{clauses: clauses}) do
    Builder.function_expression(
      [],
      [],
      Builder.block_statement(Enum.map(clauses, &Transpiler.transpile_hologram_ir!/1))
    )
  end

  # def transpile_anonymous_function(%IR.AnonymousFunctionType{
  #       clauses: [%IR.FunctionClause{params: params, body: body}]
  #     }) do
  #   function_params =
  #     Enum.with_index(params)
  #     |> Enum.map(fn
  #       {%IR.MatchPlaceholder{}, index} -> Builder.identifier("__ignored_#{index}")
  #       {%IR.Variable{name: name}, _index} -> Builder.identifier(name)
  #     end)

  #   Builder.arrow_function_expression(
  #     function_params,
  #     [],
  #     Transpiler.ControlFlow.transpile_expressions_and_return_last(body)
  #   )
  # end
end
