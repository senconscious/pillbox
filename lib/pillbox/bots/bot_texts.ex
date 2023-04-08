defmodule Pillbox.Bots.BotTexts do
  @moduledoc """
    Texts fot pillbox bot
  """

  def build_text_for_listing_courses(courses) when courses == [] do
    "No courses found"
  end

  def build_text_for_listing_courses(courses) do
    "Found #{Enum.count(courses)} courses"
  end

  def build_text_for_step(step, course_attrs) do
    case step do
      "pill_name" ->
        "Enter pill name"

      "start_date" ->
        "Enter course start date in YYYY-MM-DD format"

      "end_date" ->
        "Enter course end date in YYYY-MM-DD format"

      "confirmation" ->
        "Create course with pill name #{course_attrs.pill_name}, start date #{course_attrs.start_date} and end date #{course_attrs.end_date}"
    end
  end

  def build_text_for_failed_create_course(errors) do
    errors
    |> Enum.map(fn {key, value} ->
      [message | _tail] = value
      "#{Atom.to_string(key)} #{message}"
    end)
    |> Enum.join(", ")
    |> then(fn message -> "Failed to create course: #{message}" end)
  end

  def build_text_for_show_course(course) do
    [:pill_name, :active?, :start_date, :end_date]
    |> Enum.map(fn key -> "#{key}: #{Map.fetch!(course, key)}" end)
    |> Enum.join("\n")
  end
end
