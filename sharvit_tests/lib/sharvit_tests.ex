defmodule SharvitTests do
  def start() do
    Sharvit.Config.put_config_value(:ir_debug_mode, true)
    test_program()
  end

  def test_program() do
    # program = [SharvitTests, SharvitTests.TestModules.ProgramTest, Tuple, SharvitTests.TestModules.Strings]
    program = [SharvitTests.TestModules.Playground, Version]
    program_code = Sharvit.transpile_program!(program)

    # IO.puts(program_code)

    File.write!("out/program.js", program_code)

    IO.puts("=== Done! ===")
  end

  def test_code() do
    code = """
    case %{a: 2} do
      %{a: a = 1} when a == 1 -> a
    end
    """

    Sharvit.transpile_code!(code)
    |> IO.puts()
  end
end
