import Config

config :pillbox, ecto_repos: [Pillbox.Repo]

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 40_000]}

config :pillbox, Pillbox.Scheduler,
  jobs: [
    {"@daily", {Pillbox.Courses.CourseCommands, :update_expired_courses, []}},
    {"@daily", {Pillbox.Courses.CourseCommands, :update_started_courses, []}}
  ]

config :pillbox, Oban,
  repo: Pillbox.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [course_timetables: 5]

import_config "#{config_env()}.exs"
