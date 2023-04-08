defmodule Pillbox.Bots.BotKeyboards do
  @moduledoc """
    Keyboards for pillbox telegram bot
  """

  def build_main_menu_keyboard(telegram_id) do
    %{
      inline_keyboard: [
        [%{text: "Courses", callback_data: "list_courses"}],
        [%{text: "Pending checkings", callback_data: "list_pending_checkins_#{telegram_id}"}]
      ]
    }
  end

  def build_courses_keyboard(courses) do
    %{
      inline_keyboard: [
        [build_callback_button("start_create_course")]
        | Enum.map(courses, fn %{id: course_id, pill_name: pill_name} ->
            [
              build_callback_button("show_course_#{course_id}", pill_name),
              build_callback_button("delete_course_#{course_id}", "X")
            ]
          end)
      ]
    }
  end

  def build_list_courses_keyboard(courses) when courses != [] do
    %{
      inline_keyboard:
        Enum.map(courses, fn %{pill_name: pill_name, id: course_id} ->
          [%{text: pill_name, callback_data: "show_course_#{course_id}"}]
        end)
    }
  end

  def build_show_course_keyboard(%{id: course_id} = _course) do
    %{
      inline_keyboard: [
        [%{text: "Manage timetable", callback_data: "list_course_timetable_#{course_id}"}]
      ]
    }
  end

  def build_confirmation_create_course_keyboard do
    %{
      inline_keyboard: [
        [
          build_callback_button("confirm_create_course", "Yes"),
          build_callback_button("discard_create_course", "No")
        ]
      ]
    }
  end

  def build_timetable_keyboard(course_id, timetables) do
    %{
      inline_keyboard: [
        [build_callback_button("start_create_timetable_#{course_id}")]
        | Enum.map(timetables, fn %{id: id, pill_time: time} ->
            [
              build_callback_button("show_timetable_#{id}", "#{time}"),
              build_callback_button("delete_timetable_#{id}", "X")
            ]
          end)
      ]
    }
  end

  def build_pending_checkins_keyboard(checkins) do
    %{
      inline_keyboard: [
        Enum.map(checkins, fn %{id: checkin_id, pill_name: pill_name} ->
          build_callback_button("checkin_#{checkin_id}", "#{pill_name}")
        end)
      ]
    }
  end

  defp build_callback_button(callback_data, text \\ "+") do
    %{text: text, callback_data: callback_data}
  end
end
