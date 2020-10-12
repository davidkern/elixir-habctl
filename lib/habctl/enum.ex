defmodule HabCtl.Enum do
  def take_one(enumerable) do
    List.first(Enum.take(enumerable, 1))
  end
end
