defmodule Sharvit.Transpiler.Functions do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_function_call(
          ir ::
            IR.LocalFunctionCall.t() | IR.RemoteFunctionCall.t() | IR.AnonymousFunctionCall.t()
        ) ::
          ESTree.Node.t()
  def transpile_function_call(ir)

  def transpile_function_call(%IR.LocalFunctionCall{function: function_name, args: args}) do
    Builder.member_expression(
      Builder.this_expression(),
      Builder.identifier(Transpiler.Primitives.escape_identifier(function_name))
    )
    |> Builder.call_expression(Enum.map(args, &Transpiler.transpile_hologram_ir!/1))
  end

  def transpile_function_call(%IR.RemoteFunctionCall{
        module: %IR.AtomType{value: module_name},
        function: function_name,
        args: args
      }) do
    callee_object = Builder.identifier(Atom.to_string(module_name))
    callee_property = Builder.identifier(Transpiler.Primitives.escape_identifier(function_name))
    callee = Builder.member_expression(callee_object, callee_property)

    Builder.call_expression(callee, Enum.map(args, &Transpiler.transpile_hologram_ir!/1))
  end

  def transpile_function_call(%IR.RemoteFunctionCall{
        module: module,
        function: function_name,
        args: args
      }) do
    callee_object = Transpiler.transpile_hologram_ir!(module)
    callee_property = Builder.identifier(Transpiler.Primitives.escape_identifier(function_name))
    callee = Builder.member_expression(callee_object, callee_property)

    Builder.call_expression(callee, Enum.map(args, &Transpiler.transpile_hologram_ir!/1))
  end

  def transpile_function_call(%IR.AnonymousFunctionCall{function: function, args: args}) do
    Builder.call_expression(
      Transpiler.transpile_hologram_ir!(function),
      Enum.map(args, &Transpiler.transpile_hologram_ir!/1)
    )
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
end
