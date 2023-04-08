defmodule PillboxWeb.CheckinBotController do
  alias Pillbox.Courses
  alias Pillbox.Bots

  def list_checkins(_params, assigns, state) do
    %{
      chat_id: chat_id,
      telegram_id: telegram_id,
      token: token,
      callback_query_id: callback_query_id,
      message_id: message_id
    } = assigns

    Bots.answer_callback_query(callback_query_id, token)

    checkins = Courses.list_pending_checkins_for_telegram_user(telegram_id)

    Bots.reply_with_pending_checkins(chat_id, message_id, token, checkins)

    {:ok, state}
  end

  def checkin(_params, assigns, state) do
    %{
      chat_id: chat_id,
      checkin_id: checkin_id,
      telegram_id: telegram_id,
      token: token,
      callback_query_id: callback_query_id,
      message_id: message_id
    } = assigns

    with checkin when not is_nil(checkin) <- Courses.get_checkin(checkin_id),
         {:ok, _updated_checkin} <- Courses.update_checkin(checkin, %{checked?: true}) do
      Bots.answer_callback_query(callback_query_id, token)

      checkins = Courses.list_pending_checkins_for_telegram_user(telegram_id)

      Bots.reply_with_pending_checkins(chat_id, message_id, token, checkins)
    else
      nil ->
        Bots.answer_callback_query(callback_query_id, token, "Checkin not found")

      {:error, _changeset} ->
        Bots.answer_callback_query(callback_query_id, token, "Failed to checkin")
    end

    {:ok, state}
  end
end
