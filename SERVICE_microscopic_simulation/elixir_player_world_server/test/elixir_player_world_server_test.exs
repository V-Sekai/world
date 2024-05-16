defmodule ElixirPlayerWorldServerTest do
  use ExUnit.Case
  doctest ElixirPlayerWorldServer

  test "greets the world" do
    assert ElixirPlayerWorldServer.hello() == :world
  end
end
