use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :educate_your, EducateYourWeb.Endpoint,
  http: [:inet6, port: H.env("PORT")],
  url: [
    scheme: "https",
    host: H.env("HOST_NAME"),
    port: 443
  ],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :educate_your, EducateYour.Repo,
  ssl: true

# config :educate_your, EducateYour.Mailer,
#   adapter: Bamboo.SMTPAdapter,
#   server: System.get_env("SMTP_SERVER"),
#   port: 587,
#   username: System.get_env("SMTP_USERNAME"),
#   password: System.get_env("SMTP_PASSWORD"),
#   tls: :if_available, # other options: :always or :never
#   ssl: false,
#   retries: 1

config :logger, level: :info
