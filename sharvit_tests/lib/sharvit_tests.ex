defmodule SharvitTests do
  def start() do
    code = """
    if (1 == 2) do
      IO.inspect(1)
    end
    """



    Sharvit.transpile_code!(code)
    |> IO.puts()
  end
end
