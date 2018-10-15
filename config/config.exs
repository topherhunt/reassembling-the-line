# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
defmodule Helpers do
  def env(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")
end

use Mix.Config

# Automatically load sensitive environment variables for dev and test
if File.exists?("config/secrets.exs"), do: import_config("secrets.exs")

config :rtl,
  ecto_repos: [RTL.Repo]

config :rtl, RTL.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: Helpers.env("DATABASE_URL"),
  pool_size: Helpers.env("POOL_SIZE")

config :rtl, RTLWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: Helpers.env("SECRET_KEY_BASE"),
  render_errors: [view: RTLWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RTL.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_aws,
  access_key_id:     Helpers.env("AWS_ACCESS_KEY_ID"),
  secret_access_key: Helpers.env("AWS_SECRET_ACCESS_KEY"),
  region: "us-east-1",
  s3: [
    scheme: "https://",
    host: "s3.amazonaws.com",
    region: "us-east-1"
  ]

config :arc,
  storage: Arc.Storage.S3,
  bucket: Helpers.env("S3_BUCKET"),
  version_timeout: 600_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
