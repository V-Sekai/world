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
    {:ok, %{socket: open_socket(8000)}}
  end

  defp open_socket(port) do
    case :gen_udp.open(port, [:binary, active: false]) do
      {:ok, socket} -> socket
      {:error, :eaddrinuse} -> open_socket(port + 1)
      {:error, _reason} -> raise "Failed to open socket on port #{port}"
    end
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    entity_id = String.slice(msg, 0..3) |> String.to_integer()
    offset = entity_id * 100
    _entity_data_map = %{ip: ip, port: port, entity_id: entity_id, offset: offset, data: msg}
    File.write("entity_#{entity_id}.bin", msg)
    IO.puts("The file was saved as entity_#{entity_id}.bin!")

    send(Process.whereis(__MODULE__), {:udp, ip, port, msg})

    {:noreply, state}
  end
end

{:ok, _pid} = EntityDatabase.start_link([])
