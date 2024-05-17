# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_database.exs
# SPDX-License-Identifier: MIT

defmodule PlayerDatabase do
  def start do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    loop(socket)
  end

  defp loop(socket) do
    {:ok, {ip, port, msg}} = :gen_udp.recv(socket, 0)
    player_id = String.slice(msg, 0..3) |> String.to_integer()
    offset = player_id * 100
    player_data_map = %{ip: ip, port: port, player_id: player_id, offset: offset, data: msg}
    File.write("player_#{player_id}.bin", msg)
    IO.puts "The file was saved as player_#{player_id}.bin!"
    loop(socket)
  end
end

PlayerDatabase.start()
