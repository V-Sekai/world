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

    assert [~c"state1"] = result_buffer.payload
  end

  test "returns a tree with first child when given two states" do
    states = [{"state1", []}, {"state2", []}]
    buffer = %Buffer{payload: states}

    {{:ok,
      [buffer: {:output, %Membrane.Buffer{payload: result_buffer, pts: _, dts: _, metadata: _}}]},
     _} = StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert [~c"state1", ~c"state2"] = result_buffer
  end

  test "returns a tree with first child and next sibling when given three states" do
    states = [{"state1", []}, {"state2", []}, {"state3", []}]
    buffer = %Buffer{payload: states}

    {{:ok, [buffer: {:output, result_buffer}]}, _} =
      StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert [~c"state1", ~c"state2", ~c"state3"] = result_buffer.payload
end

  test "benchmark handle_process/4 nested" do
    payloads = [
      Enum.to_list(1..1_000) |> Enum.reduce([], fn i, acc -> [{"state#{i}", acc}] end),
      Enum.to_list(1..10_000) |> Enum.reduce([], fn i, acc -> [{"state#{i}", acc}] end),
    ]

    buffers = Enum.zip(["1_000", "10_000", "100_000"], payloads) |> Enum.map(fn {size, payload} ->
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

    assert [~c"state1", "state2", "state5", "state8", "state9", "state6", "state3", "state7", "state4"] = result_buffer
  end

  test "returns a flat list when given a nested list of states" do
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

    expected_result = [~c"state1", "state2", "state5", "state8", "state9", "state6", "state3", "state7", "state4"]

    buffer = %Buffer{payload: states}

    {{:ok,
      [buffer: {:output, %Membrane.Buffer{payload: result_buffer, pts: _, dts: _, metadata: _}}]},
     _} = StateLCRSTreeFilter.handle_process(:input, buffer, nil, %{})

    assert expected_result == result_buffer
  end
end
