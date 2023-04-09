defmodule Pillbox.Bots.CheckinCommands do
  alias Pillbox.Bots.ReplyCommands
  alias Pillbox.Courses.Checkins

  def list_checkins(assigns, state) do
    %{
      chat_id: chat_id,
      telegram_id: telegram_id,
      token: token,
      callback_query_id: callback_query_id,
      message_id: message_id
    } = assigns

    ReplyCommands.answer_callback_query(callback_query_id, token)

    checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

    ReplyCommands.reply_with_pending_checkins(chat_id, message_id, token, checkins)

    {:ok, state}
  end

  def checkin(assigns, state) do
    %{
      chat_id: chat_id,
      checkin_id: checkin_id,
      telegram_id: telegram_id,
      token: token,
      callback_query_id: callback_query_id,
      message_id: message_id
    } = assigns

    with checkin when not is_nil(checkin) <- Checkins.get_checkin(checkin_id),
         {:ok, _updated_checkin} <- Checkins.update_checkin(checkin, %{checked?: true}) do
      ReplyCommands.answer_callback_query(callback_query_id, token)

      checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

      ReplyCommands.reply_with_pending_checkins(chat_id, message_id, token, checkins)
    else
      nil ->
        ReplyCommands.answer_callback_query(callback_query_id, token, "Checkin not found")

      {:error, _changeset} ->
        ReplyCommands.answer_callback_query(callback_query_id, token, "Failed to checkin")
    end

    {:ok, state}
  end
end
