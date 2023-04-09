defmodule Pillbox.Courses.Timetables do
  @moduledoc """
    Timetables API
  """

  import Ecto.Query, only: [where: 3, order_by: 2]

  alias Pillbox.Jobs.CreateCheckinJob

  alias Pillbox.Courses.Schemas.Timetable
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
    %Timetable{}
    |> Timetable.changeset(attrs)
    |> Repo.insert()
  end

  defp insert_timetable_job(%{pill_time: pill_time, id: timetable_id}) do
    schedule_in = get_seconds_for_timetable_job(pill_time)

    %{timetable_id: timetable_id, schedule_in: schedule_in}
    |> CreateCheckinJob.new()
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

  def list_course_timetables(course_id) do
    Timetable
    |> where([table], table.course_id == ^course_id)
    |> order_by(asc: :pill_time)
    |> Repo.all()
  end

  def get_timetable(id) do
    Repo.get(Timetable, id)
  end
end
