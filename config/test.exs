use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zb, Zb.Endpoint,
  http: [port: 4001],
  server: true

# Log ALL messages (default is :warn) but route them to a logfile.
config :logger,
  backends: [{LoggerFileBackend, :test_log}]
config :logger, :test_log,
  path: "log/test.log",
  format: "$date $time $metadata[$level] $message\n",
  level: :info # :debug for ALL queries etc; :brief for only the basics

# Configure your database
config :zb, Zb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 20 * 60 * 1000

config :zb, Zb.Mailer,
  adapter: Bamboo.TestAdapter

# Reduce # of rounds when encrypting passwords (= faster test suite)
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

# See https://github.com/HashNuke/hound/blob/master/notes/configuring-hound.md
config :hound, driver: "phantomjs"
