defmodule SharvitTests do
  def start() do
    code = """
    var!([a, b]) = x
    """

    x = [1, 2]
    var!([a, b]) = x
    IO.inspect(a)
    IO.inspect(b)


    Sharvit.transpile_code!(code)
    |> IO.puts()
  end
end
