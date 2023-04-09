import Config

config :pillbox, ecto_repos: [Pillbox.Repo]

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :pillbox, Pillbox.Scheduler,
  jobs: [
    {"@daily", {Pillbox.Jobs.ExpireCoursesJob, :perform, []}},
    {"@daily", {Pillbox.Jobs.ActivateCoursesJob, :perform, []}}
  ]

config :pillbox, Oban,
  repo: Pillbox.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [course_timetables: 5]

import_config "#{config_env()}.exs"
