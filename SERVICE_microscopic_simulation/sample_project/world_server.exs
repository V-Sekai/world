# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server.exs
# SPDX-License-Identifier: MIT

defmodule Node do
  defstruct [:state, :first_child, :next_sibling]
end

defmodule WorldServer do
  use GenServer

  # Callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    player_states = %{}

    data =
      "./"
      |> Path.wildcard("*.bin")
      |> Enum.flat_map(&convert_data_to_states(File.read!(&1)))

    tree = convert_states_to_tree(data)
    processed_data = convert_tree_to_data(tree)

    File.write!("worldServer01.txt", processed_data)

    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket, player_states: player_states, processed_data: processed_data}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    player_id = String.slice(msg, 0..3) |> String.to_integer()
    player_states = Map.put(state.player_states, player_id, {ip, port})

    Process.send_after(self(), {:send_data, player_id}, 1000)

    {:noreply, %{state | player_states: player_states}}
  end

  def handle_info({:send_data, player_id}, state) do
    case Map.get(state.player_states, player_id) do
      nil -> :ok
      {ip, port} -> :gen_udp.send(state.socket, ip, port, state.processed_data)
    end

    {:noreply, state}
  end

  defp convert_data_to_states(data) do
    data
    |> String.splitter(100)
    |> Enum.take(-100)
  end

  defp convert_states_to_tree(states) do
    nodes =
      for {state, i} <- Enum.with_index(states), into: %{} do
        {i, %Node{state: state}}
      end

    for {i, node} <- nodes do
      parent = Map.get(nodes, div(i - 1, 2))

      if parent && !parent.first_child do
        Map.put(parent, :first_child, node)
      else
        sibling = parent && parent.first_child

        while sibling && sibling.next_sibling do
          sibling = sibling.next_sibling
        end

        Map.put(sibling, :next_sibling, node)
      end
    end

    Map.get(nodes, 0)
  end

  defp process_tree(nil), do: ""

  defp process_tree(%Node{} = node) do
    node.state <> process_tree(node.first_child) <> process_tree(node.next_sibling)
  end

  defp convert_tree_to_data(tree) do
    tree |> process_tree() |> String.to_charlist()
  end
end

{:ok, _pid} = WorldServer.start_link([])
