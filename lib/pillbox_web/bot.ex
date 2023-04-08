defmodule PillboxWeb.Bot do
  @doc """
    Pillbox's Telegram Bot
  """

  use Telegram.ChatBot

  alias Pillbox.BotCheckins
  alias Pillbox.BotCommands
  alias Pillbox.BotCourses
  alias Pillbox.BotTimetables

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{}}
  end

  @impl Telegram.ChatBot
  def handle_update(%{"message" => message}, token, chat_state) do
    %{message_text: message_text} = assigns = build_message_assigns(message, token)

    cond do
      start_command?(message_text) ->
        BotCommands.start(assigns, chat_state)

      create_course_action?(chat_state) ->
        BotCourses.create_course(assigns, chat_state)

      create_timetable_action?(chat_state) ->
        BotTimetables.create_timetable(assigns, chat_state)

      true ->
        BotCommands.handle_unknown_action(assigns, chat_state)
    end
  end

  @impl Telegram.ChatBot
  def handle_update(%{"callback_query" => callback_query}, token, chat_state) do
    %{action: action} = assigns = build_callback_query_assigns(callback_query, token)

    case action do
      "list_courses" ->
        BotCourses.list_courses(assigns, chat_state)

      "start_create_course" ->
        BotCourses.start_create_course(assigns, chat_state)

      "confirm_create_course" ->
        BotCourses.confirm_create_course(assigns, chat_state)

      "discard_create_course" ->
        BotCourses.discard_create_course(assigns, chat_state)

      "show_course_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> BotCourses.show_course(chat_state)

      "delete_course_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> BotCourses.delete_course(chat_state)

      "list_course_timetable_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> BotTimetables.list_timetables(chat_state)

      "start_create_timetable_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> BotTimetables.start_create_timetable(chat_state)

      "delete_timetable_" <> timetable_id ->
        assigns
        |> Map.put(:timetable_id, timetable_id)
        |> BotTimetables.delete_timetable(chat_state)

      "list_pending_checkins_" <> _telegram_id ->
        BotCheckins.list_checkins(assigns, chat_state)

      "checkin_" <> checkin_id ->
        assigns
        |> Map.put(:checkin_id, checkin_id)
        |> BotCheckins.checkin(chat_state)

      _unknown_action ->
        BotCommands.handle_unknown_query(assigns, chat_state)
    end
  end

  defp start_command?(text), do: text == "/start"

  defp create_course_action?(%{action: "create_course"}), do: true

  defp create_course_action?(_chat_state), do: false

  defp create_timetable_action?(%{action: "create_timetable"}), do: true

  defp create_timetable_action?(_chat_state), do: false

  defp build_message_assigns(message, token) do
    %{
      "chat" => %{"id" => chat_id},
      "text" => text,
      "message_id" => message_id,
      "from" => %{"id" => telegram_id}
    } = message

    %{
      token: token,
      chat_id: chat_id,
      message_text: text,
      message_id: message_id,
      telegram_id: telegram_id
    }
  end

  defp build_callback_query_assigns(callback_query, token) do
    %{
      "data" => action,
      "message" => %{
        "chat" => %{"id" => chat_id},
        "message_id" => message_id
      },
      "id" => callback_query_id,
      "from" => %{"id" => telegram_id}
    } = callback_query

    %{
      action: action,
      chat_id: chat_id,
      message_id: message_id,
      callback_query_id: callback_query_id,
      telegram_id: telegram_id,
      token: token
    }
  end
end
