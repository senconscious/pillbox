defmodule Pillbox.Courses do
  @moduledoc """
    Courses API
  """

  alias Pillbox.Courses.CourseQueries
  alias Pillbox.Courses.TimetableQueries
  alias Pillbox.Courses.CheckinQueries

  alias Pillbox.Courses.CourseCommands
  alias Pillbox.Courses.TimetableCommands
  alias Pillbox.Courses.CheckinCommands

  def create_course(attrs) do
    CourseCommands.insert_course(attrs)
  end

  def list_courses_for_telegram_user(telegram_id) do
    CourseQueries.list_courses_for_telegram_user(telegram_id)
  end

  def get_course(course_id) do
    CourseQueries.get_course(course_id)
  end

  def delete_course(course) do
    CourseCommands.delete_course(course)
  end

  def list_course_timetables(course_id) do
    TimetableQueries.list_course_timetables(course_id)
  end

  def create_timetable(attrs) do
    TimetableCommands.create_timetable(attrs)
  end

  def get_timetable(id) do
    TimetableQueries.get_timetable(id)
  end

  def delete_timetable(timetable) do
    TimetableCommands.delete_timetable(timetable)
  end

  def create_checkin(timetable_id) do
    CheckinCommands.insert_checkin(timetable_id)
  end

  def list_pending_checkins_for_telegram_user(telegram_id) do
    CheckinQueries.list_pending_checkins_for_telegram_user(telegram_id)
  end

  def get_checkin(checkin_id) when is_binary(checkin_id) do
    checkin_id
    |> String.to_integer()
    |> get_checkin()
  end

  def get_checkin(checkin_id) when is_integer(checkin_id) do
    CheckinQueries.get_checkin(checkin_id)
  end

  def update_checkin(checkin, attrs) do
    CheckinCommands.update_checkin(checkin, attrs)
  end
end
