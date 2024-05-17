# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server.exs
# SPDX-License-Identifier: MIT

defmodule WorldServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    entity_states = %{}

    # Concatenate the directory path and the file extension to form the pattern
    data =
      Path.wildcard("./" <> "*.bin")
      |> Enum.flat_map(&convert_data_to_states(File.read!(&1)))

    tree = convert_states_to_tree(data)
    processed_data = convert_tree_to_data(tree)

    File.write!("worldServer01.txt", processed_data)

    {:ok, socket} = :gen_udp.open(8000, [:binary, active: false])
    {:ok, %{socket: socket, entity_states: entity_states, processed_data: processed_data}}
  end

  def handle_info({:udp, _socket, ip, port, msg}, state) do
    entity_id = String.slice(msg, 0..3) |> String.to_integer()
    entity_states = Map.put(state.entity_states, entity_id, {ip, port})

    Process.send_after(self(), {:send_data, entity_id}, 1000)

    {:noreply, %{state | entity_states: entity_states}}
  end

  def handle_info({:send_data, entity_id}, state) do
    case Map.get(state.entity_states, entity_id) do
      nil -> :ok
      {ip, port} -> :gen_udp.send(state.socket, ip, port, state.processed_data)
    end

    {:noreply, state}
  end

  defp convert_data_to_states(data), do: convert_data_to_states(data, [])

  defp convert_data_to_states("", acc), do: Enum.reverse(acc)

  defp convert_data_to_states(data, acc) do
    {chunk, rest} = String.split_at(data, 100)
    convert_data_to_states(rest, [chunk | acc])
  end

  defp convert_states_to_tree(states) do
    StateTreeConverter.convert_states_to_tree(states)
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

{:ok, _pid} = WorldServer.start_link([])
