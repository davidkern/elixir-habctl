# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :habctl,
  namespace: HabCtl,
  ecto_repos: [HabCtl.Repo]

# Configures the endpoint
config :habctl, HabCtlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2mfT+P1z9/Ab+mfQGUDFrnlxMx8pMNFhtWSKNIDiWtsvZ3/Vwq9GhPGub65ShXMT",
  render_errors: [view: HabCtlWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HabCtl.PubSub,
  live_view: [signing_salt: "/s3CRYKR"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
