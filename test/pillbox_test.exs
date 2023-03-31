defmodule PillboxTest do
  use ExUnit.Case
  doctest Pillbox

  test "greets the world" do
    assert Pillbox.hello() == :world
  end
end
