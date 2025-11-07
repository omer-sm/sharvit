defmodule Sharvit.Js do
  @spec get_sharvit_js_code!() :: String.t()
  def get_sharvit_js_code!() do
    :code.priv_dir(:sharvit)
    |> Path.join("js/**/*.js")
    |> Path.wildcard()
    |> Enum.map_join("\n\n", &File.read!/1)
  end
end
