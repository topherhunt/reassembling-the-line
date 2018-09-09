use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :educate_your, EducateYourWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :educate_your, EducateYourWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/educate_your_web/views/.*(ex)$},
      ~r{lib/educate_your_web/templates/.*(eex|haml)$}
    ]
  ]

config :educate_your, EducateYour.Mailer,
  adapter: Bamboo.LocalAdapter

config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20 # higher stack depth (impairs performance)
