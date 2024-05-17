# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server_test.exs
# SPDX-License-Identifier: MIT

defmodule WorldServerTest do
  use ExUnit.Case, async: true

  alias WorldServer
  alias StateNode

  setup do
    {:ok, pid} = WorldServer.start_link([])
    {:ok, %{pid: pid}}
  end

  test "start_link/1 starts the server", %{pid: pid} do
    assert is_pid(pid)
  end

  test "init/1 initializes the state", %{pid: pid} do
    assert {:ok, %{socket: socket, entity_states: entity_states, processed_data: processed_data}} =
             GenServer.call(pid, :get_state)

    assert is_port(socket)
    assert is_map(entity_states)
    assert is_binary(processed_data)
  end

  test "handle_info/2 updates entity_states", %{pid: pid} do
    msg = String.duplicate("a", 104)
    ip = {127, 0, 0, 1}
    port = 12345

    send(pid, {:udp, nil, ip, port, msg})

    :timer.sleep(100)

    assert {:ok, %{entity_states: entity_states}} = GenServer.call(pid, :get_state)
    # 97 is the integer representation of "a"
    assert Map.has_key?(entity_states, 97)
  end

  test "convert_states_to_tree/1 converts states to a tree", %{pid: pid} do
    states = ["state1", "state2", "state3", "state4", "state5"]

    assert {:ok, converted_states} = GenServer.call(pid, {:convert_states_to_tree, states})

    expected_tree = %StateNode{
      state: "state1",
      first_child: %StateNode{
        state: "state2",
        first_child: %StateNode{state: "state4"},
        next_sibling: %StateNode{state: "state3", first_child: %StateNode{state: "state5"}}
      }
    }

    assert converted_states == expected_tree
  end
end
