use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rtl, RTLWeb.Endpoint,
  http: [port: 4001],
  server: true

config :logger, level: :warn

# Configure your database
config :rtl, RTL.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  # long timeout to allow debugging in tests
  ownership_timeout: 20 * 60 * 1000

config :rtl, RTL.Mailer, adapter: Bamboo.LocalAdapter

config :hound, driver: "chrome_driver", browser: "chrome_headless"

config :rollbax, enabled: false
