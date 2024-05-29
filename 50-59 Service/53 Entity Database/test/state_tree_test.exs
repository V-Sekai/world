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

  defp generate_state(i) do
    base = "state#{i}"
    String.pad_trailing(base, 100 - byte_size(base), " ")
  end

  test "benchmark handle_process/4 nested" do
    payloads = [
      Enum.to_list(1..20) |> Enum.reduce([], fn i, acc ->
        if :math.exp(:math.log10(i)) |> round == i do
          [{generate_state(i), acc}]
        else
          [{generate_state(i), List.first(acc)}]
        end
      end),
      Enum.to_list(1..100_000) |> Enum.reduce([], fn i, acc ->
        if :math.exp(:math.log10(i)) |> round == i do
          [{generate_state(i), acc}]
        else
          [{generate_state(i), List.first(acc)}]
        end
      end),
      Enum.to_list(1..300_000) |> Enum.reduce([], fn i, acc ->
        if :math.exp(:math.log10(i)) |> round == i do
          [{generate_state(i), acc}]
        else
          [{generate_state(i), List.first(acc)}]
        end
      end),
    ]

    buffers = Enum.zip(["20", "100_000", "300_000"], payloads) |> Enum.map(fn {size, payload} ->
      {size, %Buffer{payload: payload}}
    end)

    benchmarks = for {size, buffer} <- buffers do
      {:"StateLCRSTreeFilter nested #{size}", fn -> StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{}) end}
    end

    Benchee.run(Enum.into(benchmarks, %{}), time: 0.1)
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
