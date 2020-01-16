defmodule DeadendTest do
  use ExUnit.Case
  doctest Deadend

  test "greets the world" do
    assert Deadend.hello() == :world
  end
end
