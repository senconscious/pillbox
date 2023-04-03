defmodule PillboxWeb.Bot do
  @doc """
    Pillbox's Telegram Bot
  """

  use Telegram.ChatBot

  alias PillboxWeb.CommandBotController
  alias PillboxWeb.CourseBotController
  alias PillboxWeb.FallbackBotController
  alias PillboxWeb.TimetableBotController

  @impl Telegram.ChatBot
  def init(_chat) do
    {:ok, %{}}
  end

  @impl Telegram.ChatBot
  def handle_update(%{"message" => message} = params, token, chat_state) do
    %{message_text: message_text} = assigns = build_message_assigns(message, token)

    cond do
      start_command?(message_text) ->
        CommandBotController.start(params, assigns, chat_state)

      create_course_action?(chat_state) ->
        CourseBotController.create_course(params, assigns, chat_state)

      create_timetable_action?(chat_state) ->
        TimetableBotController.create_timetable(params, assigns, chat_state)

      true ->
        FallbackBotController.handle_unknown_action(params, assigns, chat_state)
    end
  end

  @impl Telegram.ChatBot
  def handle_update(%{"callback_query" => callback_query} = params, token, chat_state) do
    %{action: action} = assigns = build_callback_query_assigns(callback_query, token)

    case action do
      "list_courses" ->
        CourseBotController.list_courses(params, assigns, chat_state)

      "start_create_course" ->
        CourseBotController.start_create_course(params, assigns, chat_state)

      "confirm_create_course" ->
        CourseBotController.confirm_create_course(params, assigns, chat_state)

      "discard_create_course" ->
        CourseBotController.discard_create_course(params, assigns, chat_state)

      "show_course_" <> course_id ->
        CourseBotController.show_course(
          params,
          Map.put(assigns, :course_id, course_id),
          chat_state
        )

      "list_course_timetable_" <> course_id ->
        TimetableBotController.list_timetables(
          params,
          Map.put(assigns, :course_id, course_id),
          chat_state
        )

      "start_create_timetable_" <> course_id ->
        TimetableBotController.start_create_timetable(
          params,
          Map.put(assigns, :course_id, course_id),
          chat_state
        )

      _unknown_action ->
        FallbackBotController.handle_unknown_query(params, assigns, chat_state)
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
