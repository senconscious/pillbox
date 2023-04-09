defmodule PillboxWeb.Bot do
  @moduledoc """
    Pillbox stateful bot request handler

    Parses request type based on request params and invokes `Bots` domain.
    Currently handles only plain messages and callback queries.
    Passes either `%Pillbox.Bots.Structs.Message{}` either `%Pillbox.Bots.Structs.CallbackQuery{}`
    as first argument to domain functions
  """

  use Telegram.ChatBot

  alias Pillbox.Bots.Structs.Message
  alias Pillbox.Bots.Structs.CallbackQuery

  alias Pillbox.Bots.CheckinCommands
  alias Pillbox.Bots.Commands
  alias Pillbox.Bots.CourseCommands
  alias Pillbox.Bots.TimetableCommands

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{}}
  end

  @impl Telegram.ChatBot
  def handle_update(%{"message" => message_params}, token, chat_state) do
    %{message_text: message_text} = message = build_message_struct(message_params, token)

    cond do
      start_command?(message_text) ->
        Commands.start(message, chat_state)

      create_course_action?(chat_state) ->
        CourseCommands.create_course(message, chat_state)

      create_timetable_action?(chat_state) ->
        TimetableCommands.create_timetable(message, chat_state)

      true ->
        Commands.handle_unknown_action(message, chat_state)
    end
  end

  @impl Telegram.ChatBot
  def handle_update(%{"callback_query" => callback_query_params}, token, chat_state) do
    %{action: action} = callback_query = build_callback_query_struct(callback_query_params, token)

    case action do
      "list_courses" ->
        CourseCommands.list_courses(callback_query, chat_state)

      "start_create_course" ->
        CourseCommands.start_create_course(callback_query, chat_state)

      "confirm_create_course" ->
        CourseCommands.confirm_create_course(callback_query, chat_state)

      "discard_create_course" ->
        CourseCommands.discard_create_course(callback_query, chat_state)

      "show_course_" <> course_id ->
        CourseCommands.show_course(callback_query, course_id, chat_state)

      "delete_course_" <> course_id ->
        CourseCommands.delete_course(callback_query, course_id, chat_state)

      "list_course_timetable_" <> course_id ->
        TimetableCommands.list_timetables(callback_query, course_id, chat_state)

      "start_create_timetable_" <> course_id ->
        TimetableCommands.start_create_timetable(callback_query, course_id, chat_state)

      "delete_timetable_" <> timetable_id ->
        TimetableCommands.delete_timetable(callback_query, timetable_id, chat_state)

      "list_pending_checkins_" <> _telegram_id ->
        CheckinCommands.list_checkins(callback_query, chat_state)

      "checkin_" <> checkin_id ->
        CheckinCommands.checkin(callback_query, checkin_id, chat_state)

      _unknown_action ->
        Commands.handle_unknown_query(callback_query, chat_state)
    end
  end

  defp start_command?(text), do: text == "/start"

  defp create_course_action?(%{action: "create_course"}), do: true

  defp create_course_action?(_chat_state), do: false

  defp create_timetable_action?(%{action: "create_timetable"}), do: true

  defp create_timetable_action?(_chat_state), do: false

  defp build_message_struct(message_params, token) do
    %{
      "chat" => %{"id" => chat_id},
      "text" => text,
      "message_id" => message_id,
      "from" => %{"id" => telegram_id}
    } = message_params

    %Message{
      token: token,
      chat_id: chat_id,
      message_text: text,
      message_id: message_id,
      telegram_id: telegram_id
    }
  end

  defp build_callback_query_struct(callback_query_params, token) do
    %{
      "data" => action,
      "message" => %{
        "chat" => %{"id" => chat_id},
        "message_id" => message_id
      },
      "id" => callback_query_id,
      "from" => %{"id" => telegram_id}
    } = callback_query_params

    %CallbackQuery{
      action: action,
      chat_id: chat_id,
      message_id: message_id,
      callback_query_id: callback_query_id,
      telegram_id: telegram_id,
      token: token
    }
  end
end
