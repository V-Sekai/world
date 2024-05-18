require Logger

defmodule StateReceive do
  use Membrane.Pipeline
  alias Membrane.UDP

  @impl true
  def handle_init(_ctx, _opt) do
    spec = child(%UDP.Source{
          local_address: {127, 0, 0, 1},
          local_port_no: 8000
        })
      |> child(StateHasher)

    {[spec: spec], %{}}
  end
end
