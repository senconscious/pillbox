defmodule Pillbox.Jobs.CourseJob do
  import Ecto.Query, only: [where: 3]

  alias Pillbox.Courses.Course
  alias Pillbox.Repo

  def update_expired_courses do
    today = Date.utc_today()
    updated_at = NaiveDateTime.utc_now()

    Course
    |> where([course], course.active? and course.end_date < ^today)
    |> Repo.update_all(set: [active?: false, updated_at: updated_at])
  end

  def update_started_courses do
    today = Date.utc_today()
    updated_at = NaiveDateTime.utc_now()

    Course
    |> where([course], not course.active? and course.start_date == ^today)
    |> Repo.update_all(set: [active?: true, updated_at: updated_at])
  end
end
