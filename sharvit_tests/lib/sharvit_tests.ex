defmodule SharvitTests do
  def start() do
    code = """
    &(&1 + &2)
    """

    Sharvit.transpile_code!(code)
    |> IO.puts()
  end
end
