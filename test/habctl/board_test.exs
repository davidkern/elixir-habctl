defmodule HabCtl.BoardTest do
  use ExUnit.Case

  test "incorrect search path " do
    assert HabCtl.Board.board_temperature("notfound", "/tmp/notfound") == {:error, :not_found}
  end
end
