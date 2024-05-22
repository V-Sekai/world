{:ok, _} = :khepri.start()

id_pool = Enum.to_list(1..8000)

Enum.each(id_pool, fn id ->
  id = Integer.to_string(id) |> String.to_atom()
  :ok = :khepri.put([:players, id], %{tick_id: 0, state: <<0::100*8>>})
end)
{:ok, id_pool: id_pool}

Benchee.run(%{
  "get player state" => fn ->
    Enum.each(id_pool, fn id ->
      id = Integer.to_string(id) |> String.to_atom()
      {:ok, _} = :khepri.get([:players, id])
    end)
  end,
  "update player state" => fn ->
    Enum.each(id_pool, fn id ->
      id = Integer.to_string(id) |> String.to_atom()
      case :khepri.get([:players, id]) do
        {:ok, %{tick_id: tick_id, state: state}} ->
          new_state = %{tick_id: tick_id + 1, state: state}
          :ok = :khepri.put([:players, id], new_state)
      end
    end)
  end
})
