use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :educate_your, EducateYour.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [
    scheme: "https",
    host: Map.fetch!(System.get_env(), "HOST_NAME"),
    port: 443
  ],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json"

config :educate_your, EducateYour.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: Map.fetch!(System.get_env(), "DATABASE_URL"),
  pool_size: System.get_env("POOL_SIZE"),
  ssl: true

# Do not print debug messages in production
config :logger, level: :info
