# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_server.exs
# SPDX-License-Identifier: MIT

defmodule PlayerServer do
  def start do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    loop(socket)
  end

  defp loop(socket) do
    {:ok, {ip, port, msg}} = :gen_udp.recv(socket, 0)
    player_id = String.slice(msg, 0..3) |> String.to_integer()
    player_states = %{player_id => {ip, port}}

    {:ok, client} = :gen_udp.open(0, [:binary])
    :ok = :gen_udp.send(client, 'localhost', 10000, msg)
    :ok = :gen_udp.close(client)

    loop(socket)
  end
end

PlayerServer.start()
