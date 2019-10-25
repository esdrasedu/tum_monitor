# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tum_monitor, TumMonitorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zF3jCKxBWRPZ14BLceA59jUuvmDDSh/DefnWSwxWe+LFZIaxAY7rUqPggD3X4+6k",
  render_errors: [view: TumMonitorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TumMonitor.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "CQf8Xw_M5jWe5qkUeHZZyMghdQMUw0im"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
