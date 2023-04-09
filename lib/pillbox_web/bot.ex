defmodule PillboxWeb.Bot do
  @doc """
    Pillbox stateful bot request handler

    Parses request type based on request params and invokes `Bots` domain.
    Currently handles only plain messages and callback queries.

    Builds `assigns` based on request params and passes them into `Bots` domain.
    For more information look at `build_message_assigns/2` and `build_callback_query_assigns/2` in code

    `Bots` domain invoked with `assigns` and `chat_state`
  """

  use Telegram.ChatBot

  alias Pillbox.Bots.CheckinCommands
  alias Pillbox.Bots.Commands
  alias Pillbox.Bots.CourseCommands
  alias Pillbox.Bots.TimetableCommands

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{}}
  end

  @impl Telegram.ChatBot
  def handle_update(%{"message" => message}, token, chat_state) do
    %{message_text: message_text} = assigns = build_message_assigns(message, token)

    cond do
      start_command?(message_text) ->
        Commands.start(assigns, chat_state)

      create_course_action?(chat_state) ->
        CourseCommands.create_course(assigns, chat_state)

      create_timetable_action?(chat_state) ->
        TimetableCommands.create_timetable(assigns, chat_state)

      true ->
        Commands.handle_unknown_action(assigns, chat_state)
    end
  end

  @impl Telegram.ChatBot
  def handle_update(%{"callback_query" => callback_query}, token, chat_state) do
    %{action: action} = assigns = build_callback_query_assigns(callback_query, token)

    case action do
      "list_courses" ->
        CourseCommands.list_courses(assigns, chat_state)

      "start_create_course" ->
        CourseCommands.start_create_course(assigns, chat_state)

      "confirm_create_course" ->
        CourseCommands.confirm_create_course(assigns, chat_state)

      "discard_create_course" ->
        CourseCommands.discard_create_course(assigns, chat_state)

      "show_course_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> CourseCommands.show_course(chat_state)

      "delete_course_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> CourseCommands.delete_course(chat_state)

      "list_course_timetable_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> TimetableCommands.list_timetables(chat_state)

      "start_create_timetable_" <> course_id ->
        assigns
        |> Map.put(:course_id, course_id)
        |> TimetableCommands.start_create_timetable(chat_state)

      "delete_timetable_" <> timetable_id ->
        assigns
        |> Map.put(:timetable_id, timetable_id)
        |> TimetableCommands.delete_timetable(chat_state)

      "list_pending_checkins_" <> _telegram_id ->
        CheckinCommands.list_checkins(assigns, chat_state)

      "checkin_" <> checkin_id ->
        assigns
        |> Map.put(:checkin_id, checkin_id)
        |> CheckinCommands.checkin(chat_state)

      _unknown_action ->
        Commands.handle_unknown_query(assigns, chat_state)
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
