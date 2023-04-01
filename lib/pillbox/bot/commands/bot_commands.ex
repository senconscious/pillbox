defmodule Pillbox.BotCommands do
  @moduledoc """
    Commands for pillbox telegram bot
  """

  alias Telegram.Api, as: TelegramApi
  alias Pillbox.BotKeyboards

  def reply_with_bot_description(chat_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "sendMessage",
      chat_id: chat_id,
      text: "Hello. I can help you to track your pill intakes",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_for_list_courses(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "No pill courses found",
      reply_markup: {:json, keyboard_markup}
    )
  end

  def reply_for_create_course(chat_id, message_id, token) do
    keyboard_markup = BotKeyboards.build_main_menu_keyboard()

    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: "Forbidden to create new pill course",
      reply_markup: {:json, keyboard_markup}
    )
  end
end
