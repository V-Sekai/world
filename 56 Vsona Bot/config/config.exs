use Mix.Config

config :nostrum,
  token: System.get_env("DISCORD_API_TOKEN"),
  num_shards: 1

config :logger,
  level: :debug # :warn
