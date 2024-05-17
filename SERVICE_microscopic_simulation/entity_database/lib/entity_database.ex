# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_database.exs
# SPDX-License-Identifier: MIT

defmodule EntityDatabase do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    entity_id = String.slice(msg, 0..3) |> String.to_integer()
    offset = entity_id * 100
    entity_data_map = %{ip: ip, port: port, entity_id: entity_id, offset: offset, data: msg}
    File.write("entity_#{entity_id}.bin", msg)
    IO.puts("The file was saved as entity_#{entity_id}.bin!")

    send(Process.whereis(__MODULE__), {:udp, ip, port, msg})

    {:noreply, state}
  end
end

{:ok, _pid} = EntityDatabase.start_link([])
