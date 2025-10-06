defmodule Sharvit.Transpiler.Modules do
  alias ESTree.Tools.Builder
  alias Hologram.Compiler.IR
  alias Sharvit.Transpiler

  @ignored_module_attributes [:doc, :moduledoc, :spec, :behaviour]

  @spec transpile_module(ir :: IR.ModuleDefinition.t()) :: ESTree.VariableDeclaration.t()
  def transpile_module(
        %IR.ModuleDefinition{
          module: %IR.AtomType{value: module_name},
          body: %IR.Block{expressions: body_expressions}
        } = ir
      ) do
    class_name_identifier = Builder.identifier(Atom.to_string(module_name))

    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          class_name_identifier,
          Transpiler.ControlFlow.wrap_in_iife(
            Builder.block_statement(
              (Enum.reject(
                 body_expressions,
                 fn
                   %IR.FunctionDefinition{} ->
                     true

                   %IR.ModuleAttributeOperator{} ->
                     true

                   %IR.LocalFunctionCall{
                     function: :@,
                     args: [%IR.LocalFunctionCall{function: module_attr_name}]
                   }
                   when module_attr_name in @ignored_module_attributes ->
                     true

                   _ ->
                     false
                 end
               )
               |> Enum.map(&Transpiler.transpile_hologram_ir!/1)) ++
                [
                  Builder.return_statement(transpile_module_as_class_expression(ir))
                ]
            )
          )
        )
      ],
      :const
    )
  end

  @spec transpile_module_as_class_expression(ir :: IR.ModuleDefinition.t()) ::
          ESTree.ClassExpression.t()
  def transpile_module_as_class_expression(%IR.ModuleDefinition{} = ir) do
    method_definitions =
      IR.aggregate_module_funs(ir)
      |> Enum.map(fn {function_name, {_visibility, clauses}} ->
        Builder.method_definition(
          Builder.identifier(Transpiler.Primitives.escape_identifier(Atom.to_string(function_name))),
          Builder.function_expression(
            [],
            [],
            Builder.block_statement(
              Enum.map(clauses, &Transpiler.Functions.transpile_function_clause/1) ++
                [
                  Builder.throw_statement(
                    Builder.new_expression(
                      Builder.identifier("Error"),
                      [
                        Builder.binary_expression(
                          :+,
                          Builder.literal("No function clause matching in #{function_name}("),
                          Builder.binary_expression(
                            :+,
                            Builder.identifier("arguments"),
                            Builder.literal(")")
                          )
                        )
                      ]
                    )
                  )
                ]
            )
          ),
          :method,
          false,
          true
        )
      end)

    Builder.class_expression(Builder.class_body(method_definitions))
  end

  @doc """
  Transpile a module attribute. Only invoked for uncompiled code, as module
  attributes are injected at compile-time.
  """
  @spec transpile_module_attribute(
          ir :: IR.ModuleAttributeOperator.t() | IR.LocalFunctionCall.t()
        ) :: ESTree.Node.t()
  def transpile_module_attribute(ir)

  def transpile_module_attribute(%IR.LocalFunctionCall{
        function: :@,
        args: [%IR.LocalFunctionCall{function: attr_name, args: [attr_value]}]
      }) do
    Builder.variable_declaration(
      [
        Builder.variable_declarator(
          Builder.identifier("__moduleAttribute_#{Transpiler.Primitives.escape_identifier(attr_name)}"),
          Transpiler.transpile_hologram_ir!(attr_value)
        )
      ],
      :const
    )
  end

  def transpile_module_attribute(%IR.ModuleAttributeOperator{name: name}) do
    Builder.identifier("__moduleAttribute_#{Transpiler.Primitives.escape_identifier(name)}")
  end
end
