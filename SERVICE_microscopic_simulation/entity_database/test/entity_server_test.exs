# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_server_test.exs
# SPDX-License-Identifier: MIT

defmodule EntityServerTest do
  use ExUnit.Case, async: true

  alias EntityServer

  setup do
    {:ok, pid} = EntityServer.start_link([])
    {:ok, %{pid: pid}}
  end

  test "handle_info/2 updates entity_states", %{pid: pid} do
    msg = String.duplicate("a", 104)
    ip = {127, 0, 0, 1}
    port = 12345

    send(pid, {:udp, nil, ip, port, msg})

    :timer.sleep(100)

    assert {:ok, %{entity_states: entity_states}} = GenServer.call(pid, :get_state)
    assert Map.has_key?(entity_states, 97) # 97 is the integer representation of "a"
  end
end
