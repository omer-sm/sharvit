defmodule Sharvit.Transpiler.Patterns do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @spec transpile_pattern(ir :: IR.MatchPlaceholder.t()) :: ESTree.Node.t() | ESTree.operator()
  def transpile_pattern(ir)

  def transpile_pattern(%IR.MatchPlaceholder{}) do
    Builder.member_expression(Builder.identifier("sharvitPatterns"), Builder.identifier("any"))
  end

  def transpile_as_pattern_match(pattern, value) do
    Builder.call_expression(Builder.identifier("verifyPatternMatch"), [
      Transpiler.transpile_hologram_ir!(pattern),
      Transpiler.transpile_hologram_ir!(value)
    ])
  end
end
