defmodule Pillbox.Courses do
  @moduledoc """
    Courses API
  """

  import Ecto.Query, only: [join: 5, where: 3]

  alias Pillbox.Repo
  alias Pillbox.Courses.Course

  def create_course(attrs) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  def delete_course(course) do
    Repo.delete(course)
  end

  def list_courses_for_telegram_user(telegram_id) do
    Course
    |> join(:inner, [c], u in assoc(c, :user), as: :user)
    |> where([user: user], user.telegram_id == ^telegram_id)
    |> Repo.all()
  end

  def get_course(id) do
    Repo.get(Course, id)
  end
end
