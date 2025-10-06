defmodule Sharvit.Config do
  @moduledoc """
  Config options for Sharvit.

  ## Values

  - `:code_mode`: `:uncompiled` for transpiling uncompiled code (`Sharvit.transpile_code!/1`),
    `:compiled` for compiled code (`Sharvit.transpile_module!/1`, `Sharvit.transpile_program!/1`)
  """

  @app :sharvit

  @type sharvit_opts :: [
    code_mode: :compiled | :uncompiled,
    ir_debug_mode: boolean()
  ]

  @spec code_mode() :: :compiled | :uncompiled
  def code_mode() do
    Application.get_env(@app, :code_mode, :uncompiled)
  end

  @spec ir_debug_mode() :: boolean()
  def ir_debug_mode() do
    Application.get_env(@app, :ir_debug_mode, false)
  end

  @spec put_config_value(key :: atom(), value :: term()) :: :ok
  def put_config_value(key, value) do
    Application.put_env(@app, key, value)
  end

  @spec put_config(config :: keyword()) :: :ok
  def put_config(config) do
    Application.put_all_env([{@app, config}])
  end
end
