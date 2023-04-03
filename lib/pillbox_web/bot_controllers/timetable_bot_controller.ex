defmodule PillboxWeb.TimetableBotController do
  alias Pillbox.Bots
  alias Pillbox.Courses

  def list_timetables(_params, assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id
    } = assigns

    Bots.answer_callback_query(callback_query_id, token)

    timetables = Courses.list_course_timetables(course_id)

    Bots.reply_timetable_menu(chat_id, message_id, course_id, timetables, token)

    {:ok, state}
  end

  def start_create_timetable(_params, assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id
    } = assigns

    Bots.answer_callback_query(callback_query_id, token)

    Bots.reply_for_create_timetable(chat_id, message_id, token)

    {:ok,
     Map.merge(state, %{
       action: "create_timetable",
       step: "pill_time",
       timetable: %{course_id: course_id}
     })}
  end

  def create_timetable(_params, assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      message_text: message_text,
      token: token
    } = assigns

    %{timetable: %{course_id: course_id} = attrs, bot_message_id: bot_message_id} = state

    Bots.delete_message(chat_id, message_id, token)

    with {:ok, time} <- Time.from_iso8601(message_text),
         {:ok, _timetable} <- Courses.create_timetable(Map.put(attrs, :pill_time, time)) do
      timetables = Courses.list_course_timetables(course_id)
      Bots.reply_timetable_menu(chat_id, bot_message_id, course_id, timetables, token)

      {:ok, Map.take(state, [:user_id, :bot_message_id])}
    else
      {:error, %Ecto.Changeset{}} ->
        timetables = Courses.list_course_timetables(course_id)

        Bots.reply_with_failed_create_timetable(
          chat_id,
          bot_message_id,
          course_id,
          timetables,
          token
        )

        {:ok, Map.take(state, [:user_id, :bot_message_id])}

      {:error, _error} ->
        Bots.reply_invalid_time_input(chat_id, bot_message_id, token)

        {:ok, state}
    end
  end
end
