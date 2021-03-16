use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :rtl, RTLWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      "--color",
      "--display-error-details",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :rtl, RTLWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|scss|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/rtl_web/views/.*(ex)$},
      ~r{lib/rtl_web/templates/.*(eex)$},
      ~r{lib/rtl_web/live/*.(ex)$}
    ]
  ]

# Sent emails are captured in a local process for later inspection.
# Example:
#   MyApp.AdminEmails.unknown_heats() |> MyApp.Mailer.deliver_now()
#   Bamboo.SentEmail.all() # => a list having one %Bamboo.Email{} struct
config :rtl, RTL.Mailer, adapter: Bamboo.LocalAdapter

config :logger, level: :info # use :debug to view full sql

# higher stack depth (impairs performance)
config :phoenix, :stacktrace_depth, 20

config :rollbax, enabled: false
