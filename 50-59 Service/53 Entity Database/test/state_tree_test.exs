defmodule StateLCRSTreeFilterTest do
  use ExUnit.Case

  alias StateLCRSTreeFilter
  alias StateNode
  alias Membrane.Buffer

  test "converts state name to a list of integers" do
    state_name = "testState"
    expected_result = [116, 101, 115, 116, 83, 116, 97, 116, 101]

    assert StateLCRSTreeFilter.convert_state_to_int_list(state_name) == expected_result
  end

  test "returns a list of length 100 when given a long state name" do
    state_name = String.duplicate("a", 200)
    result = StateLCRSTreeFilter.convert_state_to_int_list(state_name)

    assert length(result) == 100
  end

  test "returns a single node tree when given a single state" do
    states = [{"state1", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert %StateNode{
             state: ~c"state1",
             first_child: nil,
             next_sibling: nil
           } = result_buffer.payload
  end

  test "returns a tree with first child when given two states" do
    states = [{"state1", []}, {"state2", []}]
    buffer = %Buffer{payload: states}

    {{:ok,
      [buffer: {:output, %Membrane.Buffer{payload: result_buffer, pts: _, dts: _, metadata: _}}]},
     _} = StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert %StateNode{
             first_child: nil,
             next_sibling: %StateNode{first_child: nil, next_sibling: nil, state: ~c"state2"},
             state: ~c"state1"
           } = result_buffer
  end

  test "returns a tree with first child and next sibling when given three states" do
    states = [{"state1", []}, {"state2", []}, {"state3", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert %StateNode{
             first_child: nil,
             next_sibling: %StateNode{
               first_child: nil,
               next_sibling: %StateNode{
                 first_child: nil,
                 next_sibling: nil,
                 state: ~c"state3"
               },
               state: ~c"state2"
             },
             state: ~c"state1"
           } = result_buffer.payload
  end

  test "returns a tree with first child and next sibling when given three states from coo" do
    states = [{"state1", []}, {"state2", []}, {"state3", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})
    assert {[0, 0, 0], [0, 1, 2], [~c"state1", ~c"state2", ~c"state3"]} = StateLCRSTreeFilter.convert_tree_to_coo(result_buffer.payload)
  end


  @tag :skip
  test "benchmark handle_process/4" do
    states = Enum.to_list(1..10_000) |> Enum.map(&{"state#{&1}", []})
    buffer = %Buffer{payload: states}

    Benchee.run(
      %{
        "StateLCRSTreeFilter" => fn ->
          StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})
        end
      },
      time: 0.1
    )
  end

  # @tag :skips
  test "benchmark handle_process/4 nested" do
    states = Enum.to_list(1..10_000) |> Enum.reduce([], fn i, acc -> [{"state#{i}", acc}] end)
    buffer = %Buffer{payload: states}

    Benchee.run(
      %{
        "StateLCRSTreeFilter nested" => fn ->
          StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})
        end
      },
      time: 0.1
    )
  end

  test "returns a nested tree when given a nested list of states" do
    states = [
      {"state1",
       [
         {"state2",
          [
            {"state5",
             [
               {"state8", []},
               {"state9", []}
             ]},
            {"state6", []}
          ]},
         {"state3",
          [
            {"state7", []}
          ]},
         {"state4", []}
       ]}
    ]

    buffer = %Buffer{payload: states}

    {{:ok,
      [buffer: {:output, %Membrane.Buffer{payload: result_buffer, pts: _, dts: _, metadata: _}}]},
     _} = StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert %StateNode{
             state: ~c"state1",
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
           } = result_buffer
  end

  def convert_tree_to_coo(tree) do
    {rows, cols, data} = do_convert_tree_to_coo(tree, {[], [], []}, {0, 0})
    {Enum.reverse(rows), Enum.reverse(cols), Enum.reverse(data)}
  end

  defp do_convert_tree_to_coo(nil, acc, _coords), do: acc

  defp do_convert_tree_to_coo(%StateNode{state: state, first_child: fc, next_sibling: ns} = _node, {rows, cols, data}, {row, col}) do
    acc = {[row | rows], [col | cols], [state | data]}

    acc = do_convert_tree_to_coo(fc, acc, {row + 1, 0})
    do_convert_tree_to_coo(ns, acc, {row, col + 1})
  end

  test "check flatten unflatten a nested tree when given a nested list of states" do
    states = [{"state1", []}, {"state2", []}, {"state3", []}, {"state4", []}, {"state5", []}]
    flattened_states = StateLCRSTreeFilter.flatten(states)
    unflattened_states = StateLCRSTreeFilter.unflatten(flattened_states)

    assert unflattened_states == states
  end

  test "check lcrs tree property" do
    states = [{"state1", []}, {"state2", []}, {"state3", []}, {"state4", []}, {"state5", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert is_lcrs_tree?(result_buffer.payload)
  end

  defp is_lcrs_tree?(nil), do: true

  defp is_lcrs_tree?(%StateNode{first_child: first_child, next_sibling: next_sibling}) do
    is_lcrs_tree?(first_child) and is_lcrs_tree?(next_sibling)
  end
end
