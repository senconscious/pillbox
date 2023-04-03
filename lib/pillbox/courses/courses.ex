defmodule Pillbox.Courses do
  @moduledoc """
    Courses API
  """

  alias Pillbox.Courses.CourseQueries
  alias Pillbox.Courses.TimetableQueries

  alias Pillbox.Courses.CourseCommands
  alias Pillbox.Courses.TimetableCommands

  def create_course(attrs) do
    CourseCommands.insert_course(attrs)
  end

  def list_courses_for_telegram_user(telegram_id) do
    CourseQueries.list_courses_for_telegram_user(telegram_id)
  end

  def get_course(course_id) do
    CourseQueries.get_course(course_id)
  end

  def list_course_timetables(course_id) do
    TimetableQueries.list_course_timetables(course_id)
  end

  def create_timetable(attrs) do
    TimetableCommands.insert_timetable(attrs)
  end
end
