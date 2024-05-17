# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# world_server.exs
# SPDX-License-Identifier: MIT

defmodule EchoFilter do
  use Membrane.Filter

  def handle_process(:input, %Membrane.Buffer{} = buffer, _ctx, state) do
    source_ip = buffer.metadata.network.source_address
    source_port = buffer.metadata.network.source_port

    new_buffer = %Membrane.Buffer{
      payload: buffer.payload,
      metadata: %{
        network: %{
          destination_address: source_ip,
          destination_port: source_port
        }
      }
    }

    actions = [
      {:buffer, :output, new_buffer}
    ]

    {{:ok, actions}, state}
  end
end

defmodule DynamicUDPSink do
  use Membrane.Sink

  def handle_write(buffer, _ctx, state) do
    destination_ip = buffer.metadata.network.destination_address
    destination_port = buffer.metadata.network.destination_port

    :gen_udp.send(state.socket, destination_ip, destination_port, buffer.payload)

    {:ok, state}
  end
end

defmodule WorldServer do
  use Membrane.Pipeline

  alias Membrane.{UDP}

  @impl true
  def handle_init(_ctx, _opts) do
    spec =
      child(%UDP.Source{
        local_address: {127, 0, 0, 1},
        local_port_no: 5001
      })
      |> child(EchoFilter)
      |> child(DynamicUDPSink)

    {[spec: spec], %{}}
  end
end
