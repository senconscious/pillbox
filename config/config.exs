import Config

config :pillbox, ecto_repos: [Pillbox.Repo]

import_config "#{config_env()}.exs"
