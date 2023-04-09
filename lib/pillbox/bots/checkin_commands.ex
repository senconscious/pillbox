defmodule Pillbox.Bots.CheckinCommands do
  @moduledoc """
    Pillbox telegram bot checkin commands
  """

  alias Pillbox.Courses.Checkins

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards

  alias Pillbox.Bots.Structs.CallbackQuery

  def list_checkins(%CallbackQuery{telegram_id: telegram_id} = assigns, state) do
    CommandAPI.answer_callback_query(assigns)

    checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

    reply_with_pending_checkins(assigns, checkins)

    {:ok, state}
  end

  def checkin(%CallbackQuery{telegram_id: telegram_id} = assigns, checkin_id, state) do
    with checkin when not is_nil(checkin) <- Checkins.get_checkin(checkin_id),
         {:ok, _updated_checkin} <- Checkins.update_checkin(checkin, %{checked?: true}) do
      CommandAPI.answer_callback_query(assigns)

      checkins = Checkins.list_pending_checkins_for_telegram_user(telegram_id)

      reply_with_pending_checkins(assigns, checkins)
    else
      nil ->
        CommandAPI.answer_callback_query(assigns, "Checkin not found")

      {:error, _changeset} ->
        CommandAPI.answer_callback_query(assigns, "Failed to checkin")
    end

    {:ok, state}
  end

  defp reply_with_pending_checkins(assigns, checkins) do
    keyboard = Keyboards.build_inline_keyboard(:pending_checkins_menu, checkins: checkins)
    text = "Pending checkins"

    CommandAPI.edit_message(assigns, text, keyboard)
  end
end
