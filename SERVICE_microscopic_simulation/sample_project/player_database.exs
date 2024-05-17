# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_database.exs
# SPDX-License-Identifier: MIT

defmodule PlayerDatabase do
  use GenServer

  # Callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    player_id = String.slice(msg, 0..3) |> String.to_integer()
    offset = player_id * 100
    player_data_map = %{ip: ip, port: port, player_id: player_id, offset: offset, data: msg}
    File.write("player_#{player_id}.bin", msg)
    IO.puts "The file was saved as player_#{player_id}.bin!"
    {:noreply, state}
  end
end

{:ok, _pid} = PlayerDatabase.start_link([])
