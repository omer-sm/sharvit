defmodule Hologram.Reflection do
  @moduledoc false

  @doc """
  Determines whether the given term is an alias.

  ## Examples

      iex> alias?(Calendar.ISO)
      true

      iex> alias?(:abc)
      false
  """
  @spec alias?(any) :: boolean
  def alias?(term)

  def alias?(term) when is_atom(term) do
    term
    |> Atom.to_string()
    |> String.starts_with?("Elixir.")
  end

  def alias?(_term), do: false
end
