defmodule EntityDatabase.Application do
  use Application

  def start(_type, _args) do
    children = [
      {WorldServer, []}
    ]

    opts = [strategy: :one_for_one, name: EntityDatabase.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
