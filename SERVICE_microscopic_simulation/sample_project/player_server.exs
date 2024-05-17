# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_server.exs
# SPDX-License-Identifier: MIT

defmodule PlayerServer do
  use GenServer

  # Callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket, player_states: %{}}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    player_id = String.slice(msg, 0..3) |> String.to_integer()
    player_states = Map.put(state.player_states, player_id, {ip, port})

    {:ok, client} = :gen_udp.open(0, [:binary])
    :ok = :gen_udp.send(client, 'localhost', 10000, msg)
    :ok = :gen_udp.close(client)

    {:noreply, %{state | player_states: player_states}}
  end
end

{:ok, _pid} = PlayerServer.start_link([])
