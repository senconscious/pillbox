defmodule Pillbox.Courses.TimetableCommands do
  alias Pillbox.Courses.TimetableWorker

  alias Pillbox.Courses.TimetableSchema
  alias Pillbox.Repo

  @one_day_in_seconds 24 * 60 * 60

  def create_timetable(attrs) do
    Repo.transaction(fn ->
      with {:ok, timetable} <- insert_timetable(attrs),
           {:ok, _job} <- insert_timetable_job(timetable) do
        timetable
      else
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp insert_timetable(attrs) do
    %TimetableSchema{}
    |> TimetableSchema.changeset(attrs)
    |> Repo.insert()
  end

  defp insert_timetable_job(%{pill_time: pill_time, id: timetable_id}) do
    schedule_in = get_seconds_for_timetable_job(pill_time)

    %{timetable_id: timetable_id, schedule_in: schedule_in}
    |> TimetableWorker.new()
    |> Oban.insert()
  end

  defp get_seconds_for_timetable_job(pill_time) do
    current_time = Time.utc_now()

    case Time.compare(pill_time, current_time) do
      :gt ->
        Time.diff(pill_time, current_time)

      :lt ->
        @one_day_in_seconds - Time.diff(current_time, pill_time)

      :eq ->
        1
    end
  end

  def delete_timetable(timetable), do: Repo.delete(timetable)
end
