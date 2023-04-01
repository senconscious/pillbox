defmodule Pillbox.Bot do
  use Telegram.Bot

  alias Pillbox.BotCommands

  @impl Telegram.Bot
  def handle_update(%{"message" => message}, token) do
    %{"chat" => %{"id" => chat_id}, "text" => text} = message

    if text == "/start" do
      BotCommands.reply_with_bot_description(chat_id, token)
    end
  end

  @impl Telegram.Bot
  def handle_update(%{"callback_query" => callback_data}, token) do
    %{"data" => action, "message" => %{"chat" => %{"id" => chat_id}, "message_id" => message_id}} =
      callback_data

    case action do
      "list_courses" ->
        BotCommands.reply_for_list_courses(chat_id, message_id, token)

      "create_course" ->
        BotCommands.reply_for_create_course(chat_id, message_id, token)

      _unknown_action ->
        :ok
    end
  end
end
