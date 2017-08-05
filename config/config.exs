# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Automatically load sensitive environment variables for dev and test
if File.exists?("config/secrets.exs"), do: import_config("secrets.exs")

# General application configuration
config :educate_your,
  ecto_repos: [EducateYour.Repo]

# Configures the endpoint
config :educate_your, EducateYour.Endpoint,
  url: [host: "localhost"],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  # TODO: Should this only be in dev and test?
  render_errors: [view: EducateYour.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EducateYour.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
# Logs print to the console by default.
config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines, haml: PhoenixHaml.Engine

# config :educate_your, EducateYour.Mailer,
#   adapter: Bamboo.SMTPAdapter,
#   server: System.get_env("SMTP_SERVER"),
#   port: 587,
#   username: System.get_env("SMTP_USERNAME"),
#   password: System.get_env("SMTP_PASSWORD"),
#   tls: :if_available, # other options: :always or :never
#   ssl: false,
#   retries: 1

config :ex_aws,
  access_key_id:     Map.fetch!(System.get_env(), "AWS_ACCESS_KEY_ID"),
  secret_access_key: Map.fetch!(System.get_env(), "AWS_SECRET_ACCESS_KEY"),
  region: "us-east-1",
  s3: [
    scheme: "https://",
    host: "s3.amazonaws.com",
    region: "us-east-1" ]

config :arc,
  storage: Arc.Storage.S3,
  bucket: Map.fetch!(System.get_env(), "S3_BUCKET"),
  version_timeout: 60_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
