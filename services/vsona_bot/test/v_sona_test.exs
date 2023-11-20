defmodule VSonaTest do
  use ExUnit.Case
  doctest VSona

  test "greets the world" do
    assert VSona.hello() == :world
  end
end
