defmodule HabCtl.Pipe do
  @doc """
  Takes one element from Enum.
  """
  def take_one(enumerable) do
    List.first(Enum.take(enumerable, 1))
  end
end
