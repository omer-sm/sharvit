defmodule SharvitTests do
  def start() do
    Sharvit.Config.put_config_value(:ir_debug_mode, true)
    test_web()
  end

  def test_web() do
    js_code = Sharvit.transpile_program!([SharvitTests.TestModules.WebTest])
    File.write!("priv/web.js", js_code)

    IO.puts("=== Done! ===")
  end

  def test_program() do
    # program = [SharvitTests, SharvitTests.TestModules.ProgramTest, Tuple, SharvitTests.TestModules.Strings]
    program = [SharvitTests.TestModules.Playground, Map]
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
