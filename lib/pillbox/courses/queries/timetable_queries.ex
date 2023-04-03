defmodule Pillbox.Courses.TimetableQueries do
  import Ecto.Query, only: [where: 3, order_by: 2]

  alias Pillbox.Courses.TimetableSchema
  alias Pillbox.Repo

  def list_course_timetables(course_id) do
    TimetableSchema
    |> where([table], table.course_id == ^course_id)
    |> order_by(asc: :pill_time)
    |> Repo.all()
  end

  def get_timetable(id) do
    Repo.get(TimetableSchema, id)
  end
end
