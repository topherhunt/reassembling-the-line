use Mix.Config

config :rtl, RTLWeb.Endpoint,
  # Heroku appears to set the PORT env automatically at startup time or something
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [scheme: "https", host: H.env!("HOST_NAME"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :rtl, RTL.Repo, ssl: true

# Do not print debug messages in production
config :logger, level: :info

config :rollbax,
  access_token: H.env!("ROLLBAR_ACCESS_TOKEN"),
  environment: "prod"

# See https://hexdocs.pm/bamboo_smtp/Bamboo.SMTPAdapter.html#module-example-config
config :rtl, RTL.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER") || raise("Missing env: SMTP_SERVER"),
  username: System.get_env("SMTP_USERNAME") || raise("Missing env: SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD") || raise("Missing env: SMTP_PASSWORD"),
  port: 587
