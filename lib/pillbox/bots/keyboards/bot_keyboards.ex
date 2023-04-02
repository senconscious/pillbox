defmodule Pillbox.BotKeyboards do
  @moduledoc """
    Keyboards for pillbox telegram bot
  """

  def build_main_menu_keyboard do
    %{
      inline_keyboard: [
        [%{text: "List my courses", callback_data: "list_courses"}],
        [%{text: "Create new course", callback_data: "start_create_course"}]
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

  def build_confirmation_create_course_keyboard do
    %{
      inline_keyboard: [
        [
          %{text: "Yes", callback_data: "confirm_create_course"},
          %{text: "No", callback_data: "discard_create_course"}
        ]
      ]
    }
  end
end
