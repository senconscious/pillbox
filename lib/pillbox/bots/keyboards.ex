defmodule Pillbox.Bots.Keyboards do
  @moduledoc """
    Provides keyboards building
  """

  @type keyboard_type() ::
          :main_menu
          | :courses_menu
          | :course_menu
          | :course_confirmation
          | :timetable_menu
          | :pending_checkins_menu

  @spec build_inline_keyboard(keyboard_type(), list()) :: map()
  def build_inline_keyboard(type, options \\ []) do
    %{
      inline_keyboard: build_buttons(type, options)
    }
  end

  defp build_buttons(:main_menu, telegram_id: telegram_id) do
    [
      [build_callback_button("list_courses", "Courses")],
      [build_callback_button("list_pending_checkins_#{telegram_id}", "Pending checkins")]
    ]
  end

  defp build_buttons(:courses_menu, courses: courses) do
    [
      [build_callback_button("start_create_course")]
      | Enum.map(courses, fn %{id: course_id, pill_name: pill_name} ->
          [
            build_callback_button("show_course_#{course_id}", pill_name),
            build_callback_button("delete_course_#{course_id}", "X")
          ]
        end)
    ]
  end

  defp build_buttons(:course_menu, course: course) do
    %{id: course_id} = course

    [
      [build_callback_button("list_course_timetable_#{course_id}", "Manage timetable")]
    ]
  end

  defp build_buttons(:course_confirmation, _options) do
    [
      [
        build_callback_button("confirm_create_course", "Yes"),
        build_callback_button("discard_create_course", "No")
      ]
    ]
  end

  defp build_buttons(:timetable_menu, course_id: course_id, timetables: timetables) do
    [
      [build_callback_button("start_create_timetable_#{course_id}")]
      | Enum.map(timetables, fn %{id: id, pill_time: time} ->
          [
            build_callback_button("show_timetable_#{id}", "#{time}"),
            build_callback_button("delete_timetable_#{id}", "X")
          ]
        end)
    ]
  end

  defp build_buttons(:pending_checkins_menu, checkins: checkins) do
    [
      Enum.map(checkins, fn %{id: checkin_id, pill_name: pill_name} ->
        build_callback_button("checkin_#{checkin_id}", "#{pill_name}")
      end)
    ]
  end

  defp build_callback_button(callback_data, text \\ "+") do
    %{text: text, callback_data: callback_data}
  end
end
