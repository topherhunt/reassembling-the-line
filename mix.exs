defmodule RTL.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rtl,
      version: "0.0.1",
      elixir: "~> 1.8.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
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
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  # Type `mix help deps` for examples and options.
  # Mix auto-starts all relevant `deps` as applications.
  defp deps do
    [
      # Core
      {:phoenix, "~> 1.4.3"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 3.6"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.13"},
      {:gettext, "~> 0.16"},
      {:jason, "~> 1.1"},
      # Keeping poison for now bc it's easier to use with Ecto jsonb storage
      {:poison, "~> 3.1"},
      {:rollbax, "~> 0.10"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:html_sanitize_ex, "~> 1.3"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:react_phoenix, "~> 1.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_auth0, "~> 0.3"},
      {:csv, "~> 2.2"},
      {:timex, "~> 3.5"},
      # TODO: when I upgrade to Ecto 3, remove this and work with plain datetimes instead
      {:timex_ecto, "~> 3.3"},
      # Downgraded to avoid presigned url bug: https://github.com/ex-aws/ex_aws/issues/602
      {:ex_aws, "~> 2.0.1"},
      {:ex_aws_s3, "~> 2.0.2"},
      {:sweet_xml, "~> 0.6"},
      {:httpotion, "~> 3.1"},
      {:hound, "~> 1.0", only: :test},
      {:logger_file_backend, "~> 0.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
    [
      test: [
        "ecto.create --quiet",
        "ecto.migrate",
        "run priv/clear_test_log.exs",
        "test"
      ],
      login: ["run priv/repo/list_autologins.exs"],
      create_user: ["run priv/repo/create_user.exs"],
      resetdb: [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate",
        "create_user \"Topher Hunt\" hunt.topher@gmail.com"
      ],
      import_youtube_videos: ["run priv/repo/import_youtube_videos.exs"]
    ]
  end
end
