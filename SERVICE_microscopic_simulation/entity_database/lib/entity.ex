# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_database_test.exs
# SPDX-License-Identifier: MIT

defmodule EntityDatabase.Entity do
  use Ecto.Schema

  import Ecto.Changeset

  schema "entities" do
    field :ip, :string
    field :port, :integer
    field :msg, :string
    field :entity_id, :integer

    timestamps()
  end

  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:ip, :port, :msg, :entity_id])
    |> validate_required([:ip, :port, :msg, :entity_id])
  end
end
