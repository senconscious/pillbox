defmodule Pillbox.Courses.CourseCommands do
  @moduledoc """
    Course commands
  """

  import Ecto.Query, only: [where: 3]

  alias Pillbox.Repo
  alias Pillbox.Courses.CourseSchema

  def insert_course(attrs) do
    %CourseSchema{}
    |> CourseSchema.changeset(attrs)
    |> Repo.insert()
  end

  def update_expired_courses do
    today = Date.utc_today()
    updated_at = NaiveDateTime.utc_now()

    CourseSchema
    |> where([course], course.active? and course.end_date < ^today)
    |> Repo.update_all(set: [active?: false, updated_at: updated_at])
  end

  def update_started_courses do
    today = Date.utc_today()
    updated_at = NaiveDateTime.utc_now()

    CourseSchema
    |> where([course], not course.active? and course.start_date == ^today)
    |> Repo.update_all(set: [active?: true, updated_at: updated_at])
  end

  def delete_course(course) do
    Repo.delete(course)
  end
end
