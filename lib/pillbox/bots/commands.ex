defmodule Pillbox.Bots.Commands do
  alias Pillbox.Accounts.Users
  alias Pillbox.Bots.ReplyCommands

  def start(assigns, _state) do
    %{chat_id: chat_id, telegram_id: telegram_id, token: token} = assigns

    %{id: user_id} = Users.get_or_create_user(telegram_id)

    {:ok, %{"message_id" => bot_message_id}} =
      ReplyCommands.reply_with_bot_description(chat_id, token, telegram_id)

    {:ok, %{user_id: user_id, bot_message_id: bot_message_id}}
  end

  def handle_unknown_query(assigns, state) do
    %{callback_query_id: callback_query_id, token: token} = assigns

    ReplyCommands.answer_unknown_callback_query(callback_query_id, token)
    {:ok, state}
  end

  def handle_unknown_action(assigns, state) do
    %{bot_message_id: bot_message_id, telegram_id: telegram_id} = state
    %{chat_id: chat_id, message_id: message_id, token: token} = assigns

    ReplyCommands.delete_message(chat_id, message_id, token)
    ReplyCommands.reply_unknown_action(chat_id, bot_message_id, token, telegram_id)
    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end
end
