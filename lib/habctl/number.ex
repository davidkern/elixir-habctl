defmodule HabCtl.Number do
  @doc """
  Formats a number to the provided decimal places (default 2).
  Converts nil to empty string.
  """
  def to_string(n, decimals \\ 2) do
    case n do
      nil -> ""
      _ -> :erlang.float_to_binary(n, [decimals: decimals])
    end
  end
end
