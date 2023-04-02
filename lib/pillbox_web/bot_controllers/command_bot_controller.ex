defmodule PillboxWeb.CommandBotController do
  alias Pillbox.Accounts
  alias Pillbox.Bots

  def start(_params, assigns, _state) do
    %{chat_id: chat_id, telegram_id: telegram_id, token: token} = assigns

    %{id: user_id} = Accounts.get_or_create_user(telegram_id)
    {:ok, %{"message_id" => bot_message_id}} = Bots.reply_with_bot_description(chat_id, token)
    {:ok, %{user_id: user_id, bot_message_id: bot_message_id}}
  end
end
