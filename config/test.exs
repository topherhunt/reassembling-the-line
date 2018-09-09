use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :educate_your, EducateYourWeb.Endpoint,
  http: [port: 4001],
  server: true

# Log ALL messages (default is :warn) but route them to a logfile.
config :logger,
  backends: [{LoggerFileBackend, :test_log}]
config :logger, :test_log,
  path: "log/test.log",
  format: "$date $time $metadata[$level] $message\n",
  level: :debug # :debug for ALL queries etc; :brief for only the basics

# Configure your database
config :educate_your, EducateYour.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 20 * 60 * 1000 # long timeout to allow debugging in tests

config :educate_your, EducateYour.Mailer,
  adapter: Bamboo.TestAdapter

config :argon2_elixir, t_cost: 1, m_cost: 8 # reduce hashing algorithm cost

config :hound, driver: "phantomjs"
