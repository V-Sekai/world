# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# entity_database_test.exs
# SPDX-License-Identifier: MIT

defmodule EntityDatabaseTest do
  use ExUnit.Case, async: true
  alias EntityDatabaseTest.Entity

  setup do
    {:ok, pid} = EntityDatabase.start_link([])
    {:ok, %{pid: pid}}
  end

  test "handle_info/2 saves the message to a file", %{pid: pid} do
    # Prepare
    ip = {127, 0, 0, 1}
    port = 1234
    msg = "0001test"
    expected_entity_id = 1
    expected_filename = "entity_#{expected_entity_id}.bin"

    # Execute
    send(pid, {:udp, :socket, ip, port, msg})

    # Assert
    assert_receive {:udp, ^ip, ^port, ^msg}
    assert File.exists?(expected_filename)
    assert File.read!(expected_filename) == msg

    # Fetch the inserted record
    inserted_entity = Repo.get(Entity, expected_entity_id)

    # Assert the inserted record
    assert inserted_entity.ip == ip
    assert inserted_entity.port == port
    assert inserted_entity.msg == msg
    assert inserted_entity.entity_id == expected_entity_id
  end
end
