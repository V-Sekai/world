# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_server.exs
# SPDX-License-Identifier: MIT

defmodule EntityServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket, entity_states: %{}}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    entity_id = String.slice(msg, 0..3) |> String.to_integer()
    entity_state = String.slice(msg, 4..103)
    entity_states = Map.put(state.entity_states, entity_id, {ip, port, entity_state})

    {:ok, client} = :gen_udp.open(0, [:binary])
    :ok = :gen_udp.send(client, 'localhost', 10000, msg)
    :ok = :gen_udp.close(client)

    {:noreply, %{state | entity_states: entity_states}}
  end
end

{:ok, _pid} = EntityServer.start_link([])
