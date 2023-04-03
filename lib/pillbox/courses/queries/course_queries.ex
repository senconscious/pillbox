defmodule Pillbox.Courses.CourseQueries do
  @moduledoc """
    Course queries
  """

  import Ecto.Query

  alias Pillbox.Repo
  alias Pillbox.Courses.CourseSchema

  def list_courses_for_telegram_user(telegram_id) do
    CourseSchema
    |> join(:inner, [c], u in assoc(c, :user), as: :user)
    |> where([user: user], user.telegram_id == ^telegram_id)
    |> Repo.all()
  end

  def get_course(id) do
    Repo.get(CourseSchema, id)
  end
end
