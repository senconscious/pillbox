defmodule Pillbox.Bots do
  @moduledoc """
    Pillbox telegram bot API
  """

  alias Telegram.Api, as: TelegramApi
  alias Pillbox.BotKeyboards
  alias Pillbox.BotTexts

  def reply_with_bot_description(chat_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "sendMessage",
      chat_id: chat_id,
      text: "Hello. I can help you to track your pill intakes",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_message(chat_id, message_id, text, token) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text
    )
  end

  def reply_unknown_action(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Sorry, can't understand request",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_no_courses(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "No courses yet",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_no_course(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Course not found",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_courses(chat_id, message_id, courses, token) do
    keyboard_markup = BotKeyboards.build_list_courses_keyboard(courses)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Your courses",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_course(chat_id, message_id, course, token) do
    keyboard_markup = BotKeyboards.build_show_course_keyboard(course)
    text = BotTexts.build_text_for_show_course(course)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_for_create_course(chat_id, message_id, token) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: BotTexts.build_text_for_step("pill_name", %{})
    )
  end

  def reply_discard_course_create(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Course not created",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_success_create_course(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Successfully created course",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_failed_create_course(chat_id, message_id, errors, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()
    text = BotTexts.build_text_for_failed_create_course(errors)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_timetable_menu(chat_id, message_id, course_id, timetables, token) do
    keyboard_markup = BotKeyboards.build_timetable_keyboard(course_id, timetables)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Timetable",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_failed_create_timetable(chat_id, message_id, course_id, timetables, token) do
    keyboard_markup = BotKeyboards.build_timetable_keyboard(course_id, timetables)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Failed to create timetable",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def get_next_step(current_step) do
    case current_step do
      "pill_name" -> "start_date"
      "start_date" -> "end_date"
      "end_date" -> "confirmation"
    end
  end

  def cast_input("pill_name", raw_data) do
    length = String.length(raw_data)

    if length >= 1 and length <= 20 do
      {:ok, raw_data}
    else
      {:error, "Pill name must be no more than 20 symbols length"}
    end
  end

  def cast_input(step, raw_data) when step in ["start_date", "end_date"] do
    with {:error, :invalid_format} <- Date.from_iso8601(raw_data) do
      {:error, "Date format must be YYYY-MM-DD"}
    end
  end

  def delete_message(chat_id, message_id, token) do
    TelegramApi.request(token, "deleteMessage", chat_id: chat_id, message_id: message_id)
  end

  def reply_for_create_timetable(chat_id, message_id, token) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Please enter time in format HH-MM-SS"
    )
  end

  def reply_with_next_step_message(chat_id, message_id, step, course_attrs, token)
      when step == "confirmation" do
    text = BotTexts.build_text_for_step(step, course_attrs)
    keyboard_markup = BotKeyboards.build_confirmation_create_course_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_with_next_step_message(chat_id, message_id, step, course_attrs, token) do
    text = BotTexts.build_text_for_step(step, course_attrs)

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text
    )
  end

  def reply_invalid_time_input(chat_id, message_id, token) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Bad format. Please enter time in HH:MM:SS format"
    )
  end

  def answer_callback_query(callback_query_id, token) do
    TelegramApi.request(token, "answerCallbackQuery", callback_query_id: callback_query_id)
  end

  def answer_unknown_callback_query(callback_query_id, token) do
    TelegramApi.request(token, "answerCallbackQuery",
      callback_query_id: callback_query_id,
      text: "Unknown query"
    )
  end

  def put_casted_data_to_course_attrs(%{course: course}, step, data) when is_map(course) do
    key =
      case step do
        "pill_name" -> :pill_name
        "start_date" -> :start_date
        "end_date" -> :end_date
      end

    Map.put(course, key, data)
  end

  def put_casted_data_to_course_attrs(_state, step, data) do
    put_casted_data_to_course_attrs(%{course: %{}}, step, data)
  end
end
