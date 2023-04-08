defmodule Pillbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    bot_config = [
      token: Application.fetch_env!(:pillbox, :bot_token),
      max_bot_concurrency: Application.fetch_env!(:pillbox, :max_bot_concurrency)
    ]

    children = [
      {Telegram.Poller, bots: [{PillboxWeb.Bot, bot_config}]},
      Pillbox.Repo,
      Pillbox.Scheduler,
      {Oban, Application.fetch_env!(:pillbox, Oban)}
      # Starts a worker by calling: Pillbox.Worker.start_link(arg)
      # {Pillbox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pillbox.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
