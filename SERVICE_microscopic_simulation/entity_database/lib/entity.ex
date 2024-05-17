# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_database_test.exs
# SPDX-License-Identifier: MIT

defmodule EntityDatabase.Entity do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "entities" do
    field :ip, :string
    field :port, :integer
    field :msg, :string
    field :entity_id, :integer

    timestamps()
  end

  def changeset(entity, {ip, port, msg, entity_id}) do
    entity
    |> cast(%{ip: ip, port: port, msg: msg, entity_id: entity_id}, [:ip, :port, :msg, :entity_id])
    |> validate_required([:ip, :port, :msg, :entity_id])
  end
end
