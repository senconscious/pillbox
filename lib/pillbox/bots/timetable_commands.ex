defmodule Pillbox.Bots.TimetableCommands do
  alias Pillbox.Courses.Timetables

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards

  alias Pillbox.Bots.Structs.Message
  alias Pillbox.Bots.Structs.CallbackQuery

  def list_timetables(%CallbackQuery{} = callback_query, course_id, state) do
    CommandAPI.answer_callback_query(callback_query)

    timetables = Timetables.list_course_timetables(course_id)

    reply_timetable_menu(callback_query, course_id, timetables)

    {:ok, Map.put(state, :course_id, course_id)}
  end

  def start_create_timetable(%CallbackQuery{} = callback_query, course_id, state) do
    CommandAPI.answer_callback_query(callback_query)

    CommandAPI.edit_message(callback_query, "Please enter time in format HH:MM:SS")

    {:ok,
     Map.merge(state, %{
       action: "create_timetable",
       step: "pill_time",
       timetable: %{course_id: course_id}
     })}
  end

  def create_timetable(%Message{message_text: message_text} = message, state) do
    %{timetable: attrs, bot_message_id: bot_message_id, course_id: course_id} = state

    CommandAPI.delete_message(message)

    with {:ok, time} <- Time.from_iso8601(message_text),
         {:ok, _timetable} <- Timetables.create_timetable(Map.put(attrs, :pill_time, time)) do
      timetables = Timetables.list_course_timetables(course_id)
      reply_timetable_menu(message, course_id, timetables)

      {:ok, Map.take(state, [:user_id, :bot_message_id, :course_id])}
    else
      {:error, %Ecto.Changeset{}} ->
        timetables = Timetables.list_course_timetables(course_id)

        reply_timetable_menu(message, course_id, timetables, "Failed to create timetable")

        {:ok, Map.take(state, [:user_id, :bot_message_id, :course_id])}

      {:error, _error} ->
        CommandAPI.edit_message(
          %{message | message_id: bot_message_id},
          "Bad format. Please enter time in HH:MM:SS format"
        )

        {:ok, state}
    end
  end

  def delete_timetable(%CallbackQuery{} = callback_query, timetable_id, state) do
    %{course_id: course_id} = state

    CommandAPI.answer_callback_query(callback_query)

    with timetable when not is_nil(timetable) <- Timetables.get_timetable(timetable_id),
         {:ok, %{course_id: course_id}} <- Timetables.delete_timetable(timetable) do
      timetables = Timetables.list_course_timetables(course_id)
      reply_timetable_menu(callback_query, course_id, timetables)

      {:ok, state}
    else
      nil ->
        timetables = Timetables.list_course_timetables(course_id)

        reply_timetable_menu(
          callback_query,
          course_id,
          timetables,
          "Timetable not found"
        )

        {:ok, state}

      {:error, _changeset} ->
        timetables = Timetables.list_course_timetables(course_id)

        reply_timetable_menu(
          callback_query,
          course_id,
          timetables,
          "Failed to delete timetable"
        )

        {:ok, state}
    end
  end

  defp reply_timetable_menu(callback_query_or_message, course_id, timetables, text \\ "Timetable") do
    keyboard =
      Keyboards.build_inline_keyboard(:timetable_menu,
        course_id: course_id,
        timetables: timetables
      )

    CommandAPI.edit_message(callback_query_or_message, text, keyboard)
  end
end
