import Config

config :pillbox, Pillbox.Repo,
  database: "pillbox_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"
