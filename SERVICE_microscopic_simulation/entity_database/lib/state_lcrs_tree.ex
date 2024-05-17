# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# state_lcrs_tree_converter.exs
# SPDX-License-Identifier: MIT

defmodule StateNode do
  defstruct [:first_child, :next_sibling, :state]
end

defmodule StateLCRSTreeFilter do
  use Membrane.Filter

  alias StateNode

  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  def handle_process(:input, buffer, _ctx, state) do
    states = buffer.payload
    tree = convert_states_to_tree(states)

    buffer = %{buffer | payload: tree}
    {{:ok, buffer: {:output, buffer}}, state}
  end

  defp convert_states_to_tree([state | _] = states) do
    %StateNode{
      state: elem(state, 0),
      first_child: convert_children(elem(state, 1)),
      next_sibling: convert_siblings(tl(states))
    }
  end

  defp convert_siblings([]), do: nil
  defp convert_siblings([head | tail]) do
    %StateNode{
      state: elem(head, 0),
      first_child: convert_children(elem(head, 1)),
      next_sibling: convert_siblings(tail)
    }
  end

  defp convert_children([]), do: nil
  defp convert_children([head | tail]) do
    %StateNode{
      state: elem(head, 0),
      first_child: convert_children(elem(head, 1)),
      next_sibling: convert_children(tail)
    }
  end
end
