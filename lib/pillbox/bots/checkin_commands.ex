defmodule Pillbox.Bots.CheckinCommands do
  alias Pillbox.Courses.Checkins

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards

  def list_checkins(assigns, state) do
    %{
      chat_id: chat_id,
      telegram_id: telegram_id,
      token: token,
      callback_query_id: callback_query_id,
      message_id: message_id
    } = assigns

    CommandAPI.answer_callback_query(callback_query_id, token)

    checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

    reply_with_pending_checkins(chat_id, message_id, token, checkins)

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
      CommandAPI.answer_callback_query(callback_query_id, token)

      checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

      reply_with_pending_checkins(chat_id, message_id, token, checkins)
    else
      nil ->
        CommandAPI.answer_callback_query(callback_query_id, token, "Checkin not found")

      {:error, _changeset} ->
        CommandAPI.answer_callback_query(callback_query_id, token, "Failed to checkin")
    end

    {:ok, state}
  end

  defp reply_with_pending_checkins(chat_id, message_id, token, checkins) do
    keyboard = Keyboards.build_inline_keyboard(:pending_checkins_menu, checkins: checkins)
    text = "Pending checkins"

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end
end
