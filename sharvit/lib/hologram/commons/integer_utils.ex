defmodule Hologram.Commons.IntegerUtils do
  @moduledoc false

  @doc """
  Parses a text representation of an integer.

  Raises an error if the text representation can't be parsed,
  or if the base is less than 2 or more than 36,
  or if only part of the text representation can be parsed.
  """
  @spec parse!(String.t(), integer) :: integer
  def parse!(binary, base \\ 10) do
    case Integer.parse(binary, base) do
      {integer, ""} ->
        integer

      :error ->
        raise ArgumentError, message: "invalid text representation"

      {_integer, _remainder} ->
        raise ArgumentError, message: "only part of the text representation can be parsed"
    end
  end
end
