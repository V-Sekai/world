defmodule StateLCRSTreeFilterTest do
  use ExUnit.Case

  alias StateLCRSTreeFilter
  alias StateNode
  alias Membrane.Buffer

  test "returns a single node tree when given a single state" do
    states = [{"state1", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert %StateNode{
             state: "state1",
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
             next_sibling: %StateNode{first_child: nil, next_sibling: nil, state: "state2"},
             state: "state1"
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
                 state: "state3"
               },
               state: "state2"
             },
             state: "state1"
           } = result_buffer.payload
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

  @tag :skip
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
           } = result_buffer
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
