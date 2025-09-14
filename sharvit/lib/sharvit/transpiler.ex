defmodule Sharvit.Transpiler do
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @binary_operators_functions [:+, :-, :*, :/, :==, :===, :|>]

  @spec transpile_hologram_ir!(ir :: IR.t()) :: ESTree.operator() | ESTree.Node.t()
  def transpile_hologram_ir!(ir)

  def transpile_hologram_ir!(%IR.Block{} = ir) do
    Transpiler.ControlFlow.transpile_control_flow(ir)
  end

  def transpile_hologram_ir!(%ir_struct{} = ir)
      when ir_struct in [IR.MatchOperator, IR.ConsOperator] do
    Transpiler.Operators.transpile_operator(ir)
  end

  def transpile_hologram_ir!(%IR.LocalFunctionCall{function: binary_operator} = ir)
      when binary_operator in @binary_operators_functions do
    Transpiler.Operators.transpile_operator(ir)
  end

  def transpile_hologram_ir!(%IR.LocalFunctionCall{function: :if} = ir) do
    Transpiler.ControlFlow.transpile_control_flow(ir)
  end

  def transpile_hologram_ir!(%IR.LocalFunctionCall{} = ir) do
    Transpiler.Functions.transpile_function_call(ir)
  end

  def transpile_hologram_ir!(%IR.RemoteFunctionCall{} = ir) do
    Transpiler.Functions.transpile_function_call(ir)
  end

  def transpile_hologram_ir!(%ir_struct{} = ir) when ir_struct in [IR.MapType, IR.ListType] do
    Transpiler.Collectables.transpile_collectable(ir)
  end

  def transpile_hologram_ir!(%ir_struct{} = ir)
      when ir_struct in [IR.AtomType, IR.StringType, IR.IntegerType, IR.FloatType] do
    Transpiler.Primitives.transpile_primitive(ir)
  end

  def transpile_hologram_ir!(unsupported_ir) do
    raise "Not yet implemented: #{inspect(unsupported_ir)}"
  end
end
