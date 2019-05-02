use Mix.Config

config :rtl, RTLWeb.Endpoint,
  # Heroku appears to set the PORT env automatically at startup time or something
  http: [:inet6, port: H.env!("PORT")],
  url: [scheme: "https", host: H.env!("HOST_NAME"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :rtl, RTL.Repo, ssl: true

# Do not print debug messages in production
config :logger, level: :info

config :rollbax,
  access_token: H.env!("ROLLBAR_ACCESS_TOKEN"),
  environment: "prod"

# Mailer config: disabled for now
# config :rtl, RTL.Mailer,
#   adapter: Bamboo.SMTPAdapter,
#   server: H.env!("SMTP_SERVER"),
#   port: 587,
#   username: H.env!("SMTP_USERNAME"),
#   password: H.env!("SMTP_PASSWORD"),
#   tls: :if_available, # other options: :always or :never
#   ssl: false,
#   retries: 1
