defmodule Pillbox.BotTimetables do
  alias Pillbox.BotReplies
  alias Pillbox.Timetables

  def list_timetables(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id
    } = assigns

    BotReplies.answer_callback_query(callback_query_id, token)

    timetables = Timetables.list_course_timetables(course_id)

    BotReplies.reply_timetable_menu(chat_id, message_id, token, course_id, timetables)

    {:ok, Map.put(state, :course_id, course_id)}
  end

  def start_create_timetable(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id
    } = assigns

    BotReplies.answer_callback_query(callback_query_id, token)

    BotReplies.reply_for_create_timetable(chat_id, message_id, token)

    {:ok,
     Map.merge(state, %{
       action: "create_timetable",
       step: "pill_time",
       timetable: %{course_id: course_id}
     })}
  end

  def create_timetable(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      message_text: message_text,
      token: token
    } = assigns

    %{timetable: attrs, bot_message_id: bot_message_id, course_id: course_id} = state

    BotReplies.delete_message(chat_id, message_id, token)

    with {:ok, time} <- Time.from_iso8601(message_text),
         {:ok, _timetable} <- Timetables.create_timetable(Map.put(attrs, :pill_time, time)) do
      timetables = Timetables.list_course_timetables(course_id)
      BotReplies.reply_timetable_menu(chat_id, bot_message_id, token, course_id, timetables)

      {:ok, Map.take(state, [:user_id, :bot_message_id, :course_id])}
    else
      {:error, %Ecto.Changeset{}} ->
        timetables = Timetables.list_course_timetables(course_id)

        BotReplies.reply_timetable_menu(
          chat_id,
          bot_message_id,
          token,
          course_id,
          timetables,
          "Failed to create timetable"
        )

        {:ok, Map.take(state, [:user_id, :bot_message_id, :course_id])}

      {:error, _error} ->
        BotReplies.reply_invalid_time_input(chat_id, bot_message_id, token)

        {:ok, state}
    end
  end

  def delete_timetable(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      callback_query_id: callback_query_id,
      token: token,
      timetable_id: timetable_id
    } = assigns

    %{course_id: course_id} = state

    BotReplies.answer_callback_query(callback_query_id, token)

    with timetable when not is_nil(timetable) <- Timetables.get_timetable(timetable_id),
         {:ok, %{course_id: course_id}} <- Timetables.delete_timetable(timetable) do
      timetables = Timetables.list_course_timetables(course_id)
      BotReplies.reply_timetable_menu(chat_id, message_id, token, course_id, timetables)

      {:ok, state}
    else
      nil ->
        timetables = Timetables.list_course_timetables(course_id)

        BotReplies.reply_timetable_menu(
          chat_id,
          message_id,
          token,
          course_id,
          timetables,
          "Timetable not found"
        )

        {:ok, state}

      {:error, _changeset} ->
        timetables = Timetables.list_course_timetables(course_id)

        BotReplies.reply_timetable_menu(
          chat_id,
          message_id,
          token,
          course_id,
          timetables,
          "Failed to delete timetable"
        )

        {:ok, state}
    end
  end
end
