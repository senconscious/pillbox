defmodule Pillbox.Bots.CommandAPI do
  @moduledoc """
    Pillbox wrapper for telegram commands
  """

  alias Telegram.Api, as: TelegramApi

  def edit_message(%{chat_id: chat_id, message_id: message_id, token: token}, text) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text
    )
  end

  def edit_message(%{chat_id: chat_id, message_id: message_id, token: token}, text, keyboard) do
    TelegramApi.request(token, "editMessageText",
      chat_id: chat_id,
      message_id: message_id,
      text: text,
      reply_markup: {:json, keyboard}
    )
  end

  def send_message(%{chat_id: chat_id, token: token}, text, keyboard) do
    TelegramApi.request(token, "sendMessage",
      chat_id: chat_id,
      text: text,
      reply_markup: {:json, keyboard}
    )
  end

  def delete_message(%{chat_id: chat_id, message_id: message_id, token: token}) do
    TelegramApi.request(token, "deleteMessage", chat_id: chat_id, message_id: message_id)
  end

  def answer_callback_query(%{callback_query_id: callback_query_id, token: token}) do
    TelegramApi.request(token, "answerCallbackQuery", callback_query_id: callback_query_id)
  end

  def answer_callback_query(%{callback_query_id: callback_query_id, token: token}, text) do
    TelegramApi.request(token, "answerCallbackQuery",
      callback_query_id: callback_query_id,
      text: text
    )
  end
end
