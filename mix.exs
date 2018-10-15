defmodule RTL.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rtl,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RTL, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  # Type `mix help deps` for examples and options.
  # Mix auto-starts all relevant `deps` as applications.
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_haml, "~> 0.2.3"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:argon2_elixir, "~> 1.2"}, # :comeonin hashing algorithm
      {:ex_machina, "~> 1.0"}, # TODO: Can we do without this now?
      {:timex, "~> 3.2"},
      {:timex_ecto, "~> 3.2"},
      {:arc, "~> 0.6.0"}, # file uploads
      {:ex_aws, "~> 1.0"}, # :arc S3 integration
      {:hackney, "~> 1.6"}, # required for :ex_aws
      {:poison, "~> 2.0"}, # required for :ex_aws
      {:sweet_xml, "~> 0.5"}, # required for :ex_aws
      {:httpotion, "~> 3.0"}, # maybe only required in tests for fetching S3 files
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4"},
      {:hound, "~> 1.0", only: :test},
      {:logger_file_backend, "~> 0.0.10", only: :test},
      {:csv, "~> 2.1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
     [
       "test": [
         "ecto.create --quiet",
         "ecto.migrate",
         "run priv/clear_test_log.exs",
         "test"]
     ]
  end
end
