# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# state_lcrs_tree_converter.exs
# SPDX-License-Identifier: MIT

defmodule StateNode do
  @type t :: %StateNode{
    state: [non_neg_integer()],
    first_child: StateNode.t() | nil,
    next_sibling: StateNode.t() | nil,
  }

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
    # Ensure each state is a list of 100 integers.
    states = Enum.map(states, fn {state_name, children} ->
      {convert_state_to_int_list(state_name), children}
    end)
    tree = convert_states_to_tree(states)

    buffer = %{buffer | payload: tree}
    {{:ok, buffer: {:output, buffer}}, state}
  end

  def convert_state_to_int_list(state_name) do
    state_name
    |> String.to_charlist()
    |> Enum.map(&rem(&1, 256))
    |> Enum.take(100)
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
  defp convert_children({state, children}) do
    %StateNode{
      state: state,
      first_child: convert_children(children),
      next_sibling: nil
    }
  end
end
