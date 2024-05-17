defmodule HasherTest do
  use ExUnit.Case

  @tag :benchmark
  test "benchmark handle_process/4" do
    Benchee.run(%{
      "handle_process/4" => fn ->
        payload = :crypto.strong_rand_bytes(1000)
        buffer = %Membrane.Buffer{payload: payload}
        state = %{}
        Hasher.handle_process(:input, buffer, nil, state)
      end
    })
  end
end
