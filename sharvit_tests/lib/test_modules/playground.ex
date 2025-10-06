defmodule SharvitTests.TestModules.Playground do
  @a %Hologram.Compiler.IR.Case{
    condition: %Hologram.Compiler.IR.MatchOperator{
      left: %Hologram.Compiler.IR.Variable{
        name: :build,
        version: 2
      },
      right: %Hologram.Compiler.IR.DotOperator{
        left: %Hologram.Compiler.IR.Variable{
          name: :version,
          version: 0
        },
        right: %Hologram.Compiler.IR.AtomType{value: :build}
      }
    },
    clauses: [
      %Hologram.Compiler.IR.Clause{
        match: %Hologram.Compiler.IR.Variable{
          name: :x,
          version: 3
        },
        guards: [
          %Hologram.Compiler.IR.RemoteFunctionCall{
            module: %Hologram.Compiler.IR.AtomType{value: :erlang},
            function: :orelse,
            args: [
              %Hologram.Compiler.IR.RemoteFunctionCall{
                module: %Hologram.Compiler.IR.AtomType{
                  value: :erlang
                },
                function: :"=:=",
                args: [
                  %Hologram.Compiler.IR.Variable{
                    name: :x,
                    version: 3
                  },
                  %Hologram.Compiler.IR.AtomType{value: false}
                ]
              },
              %Hologram.Compiler.IR.RemoteFunctionCall{
                module: %Hologram.Compiler.IR.AtomType{
                  value: :erlang
                },
                function: :"=:=",
                args: [
                  %Hologram.Compiler.IR.Variable{
                    name: :x,
                    version: 3
                  },
                  %Hologram.Compiler.IR.AtomType{value: nil}
                ]
              }
            ]
          }
        ],
        body: %Hologram.Compiler.IR.Block{
          expressions: [
            %Hologram.Compiler.IR.AtomType{value: nil}
          ]
        }
      },
      %Hologram.Compiler.IR.Clause{
        match: %Hologram.Compiler.IR.MatchPlaceholder{},
        guards: [],
        body: %Hologram.Compiler.IR.Block{
          expressions: [
            %Hologram.Compiler.IR.BitstringType{
              segments: [
                %Hologram.Compiler.IR.BitstringSegment{
                  value: %Hologram.Compiler.IR.StringType{
                    value: "+"
                  },
                  modifiers: [type: :binary]
                },
                %Hologram.Compiler.IR.BitstringSegment{
                  value: %Hologram.Compiler.IR.RemoteFunctionCall{
                    module: %Hologram.Compiler.IR.AtomType{
                      value: :Elixir_String_Chars
                    },
                    function: :to_string,
                    args: [
                      %Hologram.Compiler.IR.Variable{
                        name: :build,
                        version: 2
                      }
                    ]
                  },
                  modifiers: [type: :binary]
                }
              ]
            }
          ]
        }
      }
    ]
  }

  def t() do
    # # (a = 1) = 1
    # f2(a = 1)
    # IO.inspect([a, _] = [1, 2])
    # a.(a = 1)
    # # %{a: a = 1}
    # [a = 1]
    # {a = 1}
    # case a = 1 do
    #   a = 1 -> 1
    # end
    # cond do
    #   is_nil(a = 1) -> 1
    #   is_nil(a = 2) -> 1
    # end
  end

  def f2(version) do
    case build = version.build do
      x when :erlang.orelse(x === false, x === nil) -> nil
      _ -> "+#{build}"
    end
  end

  def f!(v) do
    [1, x = 2] = [1]
  end
end
