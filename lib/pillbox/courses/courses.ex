defmodule Pillbox.Courses do
  @moduledoc """
    Courses API
  """

  alias Pillbox.Courses.CourseQueries
  alias Pillbox.Courses.CourseCommands

  def create_course(attrs) do
    CourseCommands.insert_course(attrs)
  end

  def list_courses_for_telegram_user(telegram_id) do
    CourseQueries.list_courses_for_telegram_user(telegram_id)
  end
end
