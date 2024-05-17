defmodule StateTreeConverterTest do
  use ExUnit.Case

  alias StateTreeConverter
  alias StateNode

  test "convert_states_to_tree/1 returns a tree from states" do
    states = ["state1", "state2", "state3"]
    result = StateTreeConverter.convert_states_to_tree(states)

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
end
