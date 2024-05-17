# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# state_tree_converter_test.exs
# SPDX-License-Identifier: MIT

defmodule StateLCRSTreeConverterTest do
  use ExUnit.Case

  alias StateLCRSTreeConverter
  alias StateNode

  describe "convert_states_to_tree/1" do
    test "returns a single node tree when given a single state" do
      states = ["state1"]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)

      assert %StateNode{
               state: "state1",
               first_child: nil,
               next_sibling: nil
             } = result
    end

    test "returns a tree with first child when given two states" do
      states = ["state1", "state2"]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)

      assert %StateNode{
               state: "state1",
               first_child: %StateNode{
                 state: "state2",
                 first_child: nil,
                 next_sibling: nil
               },
               next_sibling: nil
             } = result
    end

    test "returns a tree with first child and next sibling when given three states" do
      states = ["state1", "state2", "state3"]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)

      assert %StateNode{
               state: "state1",
               first_child: %StateNode{
                 state: "state2",
                 first_child: nil,
                 next_sibling: %StateNode{
                   state: "state3",
                   first_child: nil,
                   next_sibling: nil
                 }
               },
               next_sibling: nil
             } = result
    end

    test "benchmark convert_states_to_tree/1" do
      states = Enum.to_list(1..10_000) |> Enum.map(&"state#{&1}")

      Benchee.run(%{
        "convert_states_to_tree" => fn -> StateLCRSTreeConverter.convert_states_to_tree(states) end
      })
    end
  end
end
