defmodule Sharvit.Transpiler.Clause do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler
  alias Sharvit.Transpiler.Patterns

  @enforce_keys [:patterns, :guards, :body]
  defstruct [:patterns, :guards, :body]

  @type t :: %__MODULE__{
          patterns: list(Patterns.patternable()),
          guards: list(IR.t()),
          body: IR.Block.t()
        }

  @spec to_clause(clause_ir :: IR.FunctionClause.t() | IR.Clause.t()) :: Transpiler.Clause.t()
  def to_clause(clause_ir)

  def to_clause(%IR.FunctionClause{params: params, guards: guards, body: body}) do
    clause_patterns =
      Enum.map(params, fn
        %IR.MatchOperator{left: left} -> left
        param -> param
      end)

    %Transpiler.Clause{
      patterns: clause_patterns,
      guards: guards,
      body: body
    }
  end

  def to_clause(%IR.Clause{match: pattern, guards: guards, body: body}) do
    %Transpiler.Clause{
      patterns: [pattern],
      guards: guards,
      body: body
    }
  end

  @spec transpile_clause(clause :: Transpiler.Clause.t()) :: ESTree.IfStatement.t()
  def transpile_clause(%Transpiler.Clause{
        patterns: patterns,
        guards: guards,
        body: %IR.Block{expressions: expressions}
      }) do
    clause_test = transpile_clause_test(patterns, guards)

    variables_sterilized =
      Patterns.transpile_and_sterilize_pattern(%IR.TupleType{data: patterns}, :constants)

    # TODO: improve empty detection
    variable_declaration =
      if match?(%ESTree.ArrayExpression{elements: [nil]}, variables_sterilized) ||
           match?(%ESTree.ArrayExpression{elements: []}, variables_sterilized),
         do: nil,
         else:
           Builder.variable_declaration(
             [
               Builder.variable_declarator(
                 Patterns.transpile_and_sterilize_pattern(
                   %IR.TupleType{data: patterns},
                   :constants
                 ),
                 Builder.identifier("args")
               )
             ],
             :let
           )

    expressions_transpiled =
      Transpiler.Blocks.transpile_expressions_and_return_last(expressions)
      |> then(fn
        %ESTree.BlockStatement{body: body} -> body
        statement_transpiled -> [statement_transpiled]
      end)

    body_transpiled =
      if is_nil(variable_declaration),
        do: Builder.block_statement(expressions_transpiled),
        else:
          Builder.block_statement([
            variable_declaration
            | expressions_transpiled
          ])

    Builder.if_statement(clause_test, body_transpiled)
  end

  defp transpile_clause_test(patterns, guards)

  defp transpile_clause_test(patterns, []) do
    Builder.call_expression(
      Builder.identifier("doesMatchPattern"),
      [
        Builder.array_expression(
          Enum.map(patterns, &Patterns.transpile_and_sterilize_pattern(&1, :variables))
        ),
        Builder.identifier("args")
      ]
    )
  end

  defp transpile_clause_test(patterns, guards) do
    does_match_test = transpile_clause_test(patterns, [])

    guards_test =
      Builder.call_expression(
        Builder.arrow_function_expression(
          Enum.map(patterns, &Patterns.transpile_and_sterilize_pattern(&1, :constants)),
          [],
          transpile_guards(guards),
          false,
          true
        ),
        [
          Builder.rest_element(Builder.identifier("args"))
        ]
      )

    Builder.logical_expression(
      :&&,
      does_match_test,
      guards_test
    )
  end

  defp transpile_guards([guard]) do
    Transpiler.transpile_hologram_ir!(guard)
  end

  defp transpile_guards([guard | rest]) do
    Builder.logical_expression(
      :||,
      Transpiler.transpile_hologram_ir!(guard),
      transpile_guards(rest)
    )
  end
end
