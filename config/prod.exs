use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :rtl, RTLWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT")],
  url: [
    scheme: "https",
    host: System.get_env("HOST_NAME"),
    port: 443
  ],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :rtl, RTL.Repo, ssl: true

# config :rtl, RTL.Mailer,
#   adapter: Bamboo.SMTPAdapter,
#   server: System.get_env("SMTP_SERVER"),
#   port: 587,
#   username: System.get_env("SMTP_USERNAME"),
#   password: System.get_env("SMTP_PASSWORD"),
#   tls: :if_available, # other options: :always or :never
#   ssl: false,
#   retries: 1

config :logger, level: :info
