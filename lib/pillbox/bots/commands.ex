defmodule Pillbox.Bots.Commands do
  @moduledoc """
    Pillbox telegram bot general commands like `/start`
  """

  alias Pillbox.Accounts.Users

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards

  alias Pillbox.Bots.Structs.CallbackQuery
  alias Pillbox.Bots.Structs.Message

  def start(%Message{telegram_id: telegram_id} = message, _state) do
    %{id: user_id} = Users.get_or_create_user(telegram_id)

    {:ok, %{"message_id" => bot_message_id}} = reply_with_bot_description(message, telegram_id)

    {:ok, %{user_id: user_id, bot_message_id: bot_message_id}}
  end

  def handle_unknown_query(%CallbackQuery{} = callback_query, state) do
    CommandAPI.answer_callback_query(callback_query, "Unknown query")

    {:ok, state}
  end

  def handle_unknown_action(%Message{} = message, state) do
    %{bot_message_id: bot_message_id, telegram_id: telegram_id} = state

    CommandAPI.delete_message(message)
    reply_unknown_action(%{message | message_id: bot_message_id}, telegram_id)

    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  defp reply_unknown_action(%Message{} = message, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)
    text = "Sorry, can't understand request"

    CommandAPI.edit_message(message, text, keyboard)
  end

  defp reply_with_bot_description(%Message{} = message, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)

    text =
      "Hello. I can help you to track your pill intakes. Note that currently only UTC timezone supported"

    CommandAPI.send_message(message, text, keyboard)
  end
end
