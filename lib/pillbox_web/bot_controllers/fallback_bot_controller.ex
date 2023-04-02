defmodule PillboxWeb.FallbackBotController do
  alias Pillbox.Bots

  def handle_unknown_query(_params, assigns, state) do
    %{callback_query_id: callback_query_id, token: token} = assigns

    Bots.answer_unknown_callback_query(callback_query_id, token)
    {:ok, state}
  end

  def handle_unknown_action(_params, assigns, state) do
    %{bot_message_id: bot_message_id} = state
    %{chat_id: chat_id, message_id: message_id, token: token} = assigns

    Bots.delete_message(chat_id, message_id, token)
    Bots.reply_unknown_action(chat_id, bot_message_id, token)
    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end
end
