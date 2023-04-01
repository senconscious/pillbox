import Config

config :pillbox, ecto_repos: [Pillbox.Repo]

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

import_config "#{config_env()}.exs"
