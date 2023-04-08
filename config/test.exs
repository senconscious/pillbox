import Config

config :pillbox, Pillbox.Repo,
  database: "pillbox_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :pillbox, Oban, testing: :inline
