import Config

config :pillbox, Pillbox.Repo,
  database: "pillbox_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :pillbox,
  max_bot_concurrency: 2
