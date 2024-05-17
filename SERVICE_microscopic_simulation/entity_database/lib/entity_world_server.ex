# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server.exs
# SPDX-License-Identifier: MIT

# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server.exs
# SPDX-License-Identifier: MIT

defmodule WorldServer do
  use GenServer
  alias EntityDatabaseTest.Entity
  alias Ecto.Adapters.SQL.Sandbox

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    entity_id = String.slice(msg, 0..3) |> String.to_integer()

    # Create a new entity and insert it into the database
  end

  def handle_info({:send_data, entity_id}, state) do
    # Create a new entity and insert it into the database

    {:noreply, state}
  end

  defp convert_data_to_states(data), do: convert_data_to_states(data, [])

  defp convert_data_to_states("", acc), do: Enum.reverse(acc)

  defp convert_data_to_states(data, acc) do
    {chunk, rest} = String.split_at(data, 100)
    convert_data_to_states(rest, [chunk | acc])
  end

  defp convert_states_to_tree(states) do
    StateLCRSTree.convert_states_to_tree(states)
  end

  defp process_tree(nil), do: ""

  defp process_tree(%StateNode{} = node) do
    node.state <> process_tree(node.first_child) <> process_tree(node.next_sibling)
  end

  defp convert_tree_to_data(tree) do
    tree |> process_tree() |> String.to_charlist()
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}
end
