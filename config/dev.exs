import Config

config :pillbox, Pillbox.Repo,
  database: "pillbox_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :pillbox,
  bot_token: "6071651122:AAEMVbU1dRe97Zhc9MVt8xrW5LUhBspZPmw",
  max_bot_concurrency: 2
