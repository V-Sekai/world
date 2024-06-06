defmodule EntityDatabase.MixProject do
  use Mix.Project

  def project do
    [
      app: :entity_database,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:membrane_core, "~> 1.0"},
      {:membrane_udp_plugin, "~> 0.13.0"},
      {:membrane_file_plugin, "~> 0.16"},
      {:benchee, "~> 1.0", only: [:dev, :test]},
      {:nx, "~> 0.5"},
      {:torchx, "~> 0.5"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
