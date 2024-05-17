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
      states = [{"state1", []}]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)

      assert %StateNode{
               state: "state1",
               first_child: nil,
               next_sibling: nil
             } = result
    end

    test "returns a tree with first child when given two states" do
      states = [{"state1", []}, {"state2", []}]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)
      assert %StateNode{first_child: nil, next_sibling: %StateNode{first_child: nil, next_sibling: nil, state: "state2"}, state: "state1"} = result
    end

    test "returns a tree with first child and next sibling when given three states" do
      states = [{"state1", []}, {"state2", []}, {"state3", []}]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)
      assert %StateNode{
        first_child: nil,
        next_sibling: %StateNode{first_child: nil, next_sibling: %StateNode{first_child: nil, next_sibling: nil, state: "state3"}, state: "state2"},
        state: "state1"
      } = result
    end

    # @tag :skip
    test "benchmark convert_states_to_tree/1" do
      states = Enum.to_list(1..10_000) |> Enum.map(&{"state#{&1}", []})

      Benchee.run(%{
        "convert_states_to_tree" => fn -> StateLCRSTreeConverter.convert_states_to_tree(states) end
      },
      time: 0.1)
    end

    # @tag :skip
    test "benchmark convert_states_to_tree/1 nested" do
      states = Enum.to_list(1..10_000) |> Enum.reduce([], fn i, acc -> [{"state#{i}", acc}] end)

      Benchee.run(%{
        "convert_states_to_tree nested" => fn -> StateLCRSTreeConverter.convert_states_to_tree(states) end
      },
      time: 0.1)
    end

    test "returns a nested tree when given a nested list of states" do
      states = [
        {"state1", [
          {"state2", [
            {"state5", [
              {"state8", []},
              {"state9", []}
            ]},
            {"state6", []}
          ]},
          {"state3", [
            {"state7", []}
          ]},
          {"state4", []}
        ]}
      ]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)
      assert %StateNode{
        state: "state1",
        first_child: %StateNode{
          state: "state2",
          first_child: %StateNode{
            state: "state5",
            first_child: %StateNode{
              state: "state8",
              first_child: nil,
              next_sibling: %StateNode{
                state: "state9",
                first_child: nil,
                next_sibling: nil
              }
            },
            next_sibling: %StateNode{
              state: "state6",
              first_child: nil,
              next_sibling: nil
            }
          },
          next_sibling: %StateNode{
            state: "state3",
            first_child: %StateNode{
              state: "state7",
              first_child: nil,
              next_sibling: nil
            },
            next_sibling: %StateNode{
              state: "state4",
              first_child: nil,
              next_sibling: nil
            }
          }
        },
        next_sibling: nil
      } = result
    end

    test "check lcrs tree property" do
      states = [{"state1", []}, {"state2", []}, {"state3", []}, {"state4", []}, {"state5", []}]
      result = StateLCRSTreeConverter.convert_states_to_tree(states)
      assert is_lcrs_tree?(result)
    end
    defp is_lcrs_tree?(nil), do: true
    defp is_lcrs_tree?(%StateNode{first_child: first_child, next_sibling: next_sibling}) do
      is_lcrs_tree?(first_child) and is_lcrs_tree?(next_sibling)
    end
  end
end
