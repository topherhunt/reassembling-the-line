defmodule EducateYour.Mixfile do
  use Mix.Project

  def project do
    [app: :educate_your,
     version: "0.0.1",
     elixir: "1.3.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    apps = %{
      global: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :phoenix_ecto, :postgrex, :comeonin, :timex, :timex_ecto, :ex_machina, :ex_aws, :hackney, :poison, :httpotion, :bamboo],
      dev:  [],
      test: [:hound],
      prod: []
    }
    [ mod: {EducateYour, []},
      applications: apps[:global] ++ apps[Mix.env] ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_haml, "~> 0.2.1"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 2.0"},
      {:ex_machina, "~> 1.0"}, # factory (useful both in tests and seeds)
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
      {:arc, "~> 0.6.0"},
      {:ex_aws, "~> 1.0"}, # arc requires ex_aws 1.0 (for S3 upload)
      {:hackney, "~> 1.6"}, # required by ex_aws
      {:poison, "~> 2.0"}, # required by ex_aws
      {:sweet_xml, "~> 0.5"}, # required by ex_aws
      {:httpotion, "~> 3.0"}, # maybe only required in tests for fetching S3 files
      # ^ If this gives me any trouble, consider httpoison instead
      {:bamboo, "~> 0.7"},
      {:bamboo_smtp, "~> 1.2.1"},
      {:hound, "~> 1.0", only: :test},
      {:logger_file_backend, "~> 0.0.9", only: :test},
      {:csv, "~> 2.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
     [
       "ecto.reset": [
         "ecto.drop",
         "ecto.create",
         "ecto.migrate",
         "run priv/repo/seeds.exs"],
       "ecto.reset_test": [
         "ecto.drop",
         "ecto.create",
         "ecto.migrate"], # no seeds
       "test": [
         "ecto.create --quiet",
         "ecto.migrate",
         "run priv/clear_test_log.exs", # Clear test logs before each run
         "test"]
     ]
  end
end
