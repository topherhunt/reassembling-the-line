# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

use Mix.Config

# Duplicate since I don't think I can easily include modules from lib/ here
defmodule H do
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")
end

# Automatically load sensitive environment variables for dev and test
if File.exists?("config/secrets.exs"), do: import_config("secrets.exs")

config :rtl,
  ecto_repos: [RTL.Repo]

config :rtl, RTL.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: H.env!("DATABASE_URL"),
  # Heroku PG hobby-dev allows max 20 db connections, so 10 is safe
  pool_size: 10,
  loggers: [{RTL.Repo, :log_query, []}]

config :rtl, RTLWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: H.env!("SECRET_KEY_BASE"),
  render_errors: [view: RTLWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RTL.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: H.env!("SIGNING_SALT")]

config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

config :phoenix, :json_library, Jason

# Scrub these params from the logs
config :phoenix, :filter_parameters, ["password", "admin_password"]

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_aws,
  access_key_id: H.env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: H.env!("AWS_SECRET_ACCESS_KEY"),
  region: H.env!("S3_REGION"), # TODO: redundant?
  s3: [
    scheme: "https://",
    # NOTE: In mid-2020 S3 is moving to a "virtual host" format where the bucket is
    # prefixed to the host, e.g. rtl-prod-eu.s3.amazonaws.com.
    # More info: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
    host: H.env!("S3_HOST"),
    region: H.env!("S3_REGION")
  ],
  mediaconvert: [
    host: H.env!("MEDIACONVERT_API_ENDPOINT")
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
