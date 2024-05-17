# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# state_tree_converter.exs
# SPDX-License-Identifier: MIT

defmodule StateNode do
  defstruct [:state, :first_child, :next_sibling]
end

defmodule StateTreeConverter do
  alias StateNode

  def convert_states_to_tree(states) do
    build_tree(Enum.reverse(states), nil)
  end

  defp build_tree([], _parent), do: _parent

  defp build_tree([state | rest], parent) do
    node = %StateNode{
      state: state,
      first_child: nil,
      next_sibling: nil
    }

    if parent do
      case parent.first_child do
        nil ->
          parent = Map.put(parent, :first_child, node)

        _ ->
          last_sibling =
            Enum.reduce_while(parent.first_child, fn
              %{next_sibling: nil} = sib, _ -> {:halt, sib}
              sib, _ -> {:cont, sib.next_sibling}
            end)

          last_sibling = Map.put(last_sibling, :next_sibling, node)
          parent = Map.put(parent, :first_child, last_sibling)
      end
    end

    build_tree(rest, node)
  end
end
