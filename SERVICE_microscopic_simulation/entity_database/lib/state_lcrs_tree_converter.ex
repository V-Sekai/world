# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# state_lcrs_tree_converter.exs
# SPDX-License-Identifier: MIT

defmodule StateNode do
  defstruct [:state, :first_child, :next_sibling]
end

defmodule StateLCRSTreeConverter do
  alias StateNode

  def convert_states_to_tree(states) do
    build_tree(states, nil)
  end

  defp build_tree([], parent), do: parent

  defp build_tree([state | rest], parent) do
    node = %StateNode{
      state: state,
      first_child: nil,
      next_sibling: nil
    }

    updated_parent =
      if parent do
        case parent.first_child do
          nil ->
            %{parent | first_child: node}

          _ ->
            last_sibling = find_last_sibling(parent.first_child)
            updated_sibling = %{last_sibling | next_sibling: node}
            %{parent | first_child: updated_sibling}
        end
      else
        node
      end

    build_tree(rest, updated_parent)
  end

  defp find_last_sibling(%StateNode{next_sibling: nil} = sibling), do: sibling
  defp find_last_sibling(%StateNode{next_sibling: next_sibling}), do: find_last_sibling(next_sibling)
end
