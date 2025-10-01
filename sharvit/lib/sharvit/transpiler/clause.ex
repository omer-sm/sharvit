defmodule Sharvit.Transpiler.Clause do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler
  alias Sharvit.Transpiler.Patterns

  @enforce_keys [:params, :patterns, :guards, :body]
  defstruct [:params, :patterns, :guards, :body]

  @type t :: %__MODULE__{
          params: list(IR.Variable.t() | IR.MatchPlaceholder.t()),
          patterns: list(Patterns.patternable()),
          guards: list(IR.t()),
          body: IR.Block.t()
        }

  @spec to_clause(clause_ir :: IR.FunctionClause.t() | IR.Clause.t()) :: Transpiler.Clause.t()
  def to_clause(clause_ir)

  def to_clause(%IR.FunctionClause{params: params, guards: guards, body: body}) do
    clause_params =
      Enum.map(params, fn
        %IR.Variable{} = param -> param
        %IR.MatchOperator{right: right} -> right
        _ -> %IR.MatchPlaceholder{}
      end)

    clause_patterns =
      Enum.map(params, fn
        %IR.MatchOperator{left: left} -> left
        param -> param
      end)

    %Transpiler.Clause{
      params: clause_params,
      patterns: clause_patterns,
      guards: guards,
      body: body
    }
  end

  def to_clause(%IR.Clause{
        match: %IR.MatchOperator{left: pattern, right: param},
        guards: guards,
        body: body
      }) do
    %Transpiler.Clause{
      params: [param],
      patterns: [pattern],
      guards: guards,
      body: body
    }
  end

  def to_clause(%IR.Clause{match: pattern, guards: guards, body: body}) do
    %Transpiler.Clause{
      params: [],
      patterns: [pattern],
      guards: guards,
      body: body
    }
  end

  @spec transpile_clause(clause :: Transpiler.Clause.t()) :: ESTree.IfStatement.t()
  def transpile_clause(%Transpiler.Clause{
        params: params,
        patterns: patterns,
        guards: guards,
        body: %IR.Block{expressions: expressions}
      }) do
    clause_test = transpile_clause_test(patterns, guards, params)

    variable_declaration =
      if match?([], params),
        do: nil,
        else:
          Builder.variable_declaration(
            [
              Builder.variable_declarator(
                Patterns.transpile_and_sterilize_pattern(%IR.TupleType{data: params}, :constants),
                Builder.identifier("arguments")
              )
            ],
            :let
          )

    expressions_transpiled =
      Transpiler.ControlFlow.transpile_expressions_and_return_last(expressions)
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

  defp transpile_clause_test(patterns, guards, params)

  defp transpile_clause_test(patterns, [], _params) do
    Builder.call_expression(
      Builder.identifier("doesMatchPattern"),
      [
        Builder.array_expression(
          Enum.map(patterns, &Patterns.transpile_and_sterilize_pattern(&1, :variables))
        ),
        Builder.identifier("arguments")
      ]
    )
  end

  defp transpile_clause_test(patterns, guards, params) do
    does_match_test = transpile_clause_test(patterns, [], nil)

    guards_test =
      Builder.call_expression(
        Builder.arrow_function_expression(
          Enum.map(params, &Patterns.transpile_and_sterilize_pattern(&1, :constants)),
          [],
          transpile_guards(guards),
          false,
          true
        ),
        [
          Builder.rest_element(Builder.identifier("arguments"))
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
