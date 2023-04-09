defmodule Pillbox.Jobs.CreateCheckinJob do
  use Oban.Worker, queue: :checkins, max_attempts: 1

  alias Pillbox.Courses.Checkins

  @one_day_in_seconds 24 * 60 * 60

  @impl true
  def perform(%{args: %{"timetable_id" => timetable_id} = args, attempt: 1}) do
    args
    |> new(schedule_in: @one_day_in_seconds)
    |> Oban.insert!()

    Checkins.create_checkin(timetable_id)
  end
end
