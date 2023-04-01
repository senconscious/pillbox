defmodule Pillbox.BotKeyboards do
  def build_main_menu_keyboard do
    %{
      inline_keyboard: [
        [%{text: "List my courses", callback_data: "list_courses"}],
        [%{text: "Create new course", callback_data: "create_course"}]
      ]
    }
  end
end
