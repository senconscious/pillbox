defmodule Pillbox.Bots.Commands do
  alias Pillbox.Accounts.Users

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards

  def start(assigns, _state) do
    %{chat_id: chat_id, telegram_id: telegram_id, token: token} = assigns

    %{id: user_id} = Users.get_or_create_user(telegram_id)

    {:ok, %{"message_id" => bot_message_id}} =
      reply_with_bot_description(chat_id, token, telegram_id)

    {:ok, %{user_id: user_id, bot_message_id: bot_message_id}}
  end

  def handle_unknown_query(assigns, state) do
    %{callback_query_id: callback_query_id, token: token} = assigns

    answer_unknown_callback_query(callback_query_id, token)
    {:ok, state}
  end

  def handle_unknown_action(assigns, state) do
    %{bot_message_id: bot_message_id, telegram_id: telegram_id} = state
    %{chat_id: chat_id, message_id: message_id, token: token} = assigns

    CommandAPI.delete_message(chat_id, message_id, token)
    reply_unknown_action(chat_id, bot_message_id, token, telegram_id)
    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  defp reply_unknown_action(chat_id, message_id, token, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)
    text = "Sorry, can't understand request"

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_with_bot_description(chat_id, token, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)

    text =
      "Hello. I can help you to track your pill intakes. Note that currently only UTC timezone supported"

    CommandAPI.send_message(chat_id, token, text, keyboard)
  end

  def answer_unknown_callback_query(callback_query_id, token) do
    text = "Unknown query"
    CommandAPI.answer_callback_query(callback_query_id, token, text)
  end
end
