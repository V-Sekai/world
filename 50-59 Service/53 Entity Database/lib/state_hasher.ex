defmodule StateHasher do
  use Membrane.Filter
  require Logger

  def handle_process(:input, %Membrane.Buffer{payload: payload}, _ctx, state) do
    hash = compute_hash(payload)

    log_hash(hash)

    {{:ok, buffer: {:output, payload}}, state}
  end

  defp compute_hash(payload) do
    :crypto.hash(:sha256, payload)
  end

  defp log_hash(hash) do
    Logger.info("Hash: #{Base.encode16(hash)}")
  end
end
