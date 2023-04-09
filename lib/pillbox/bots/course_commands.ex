defmodule Pillbox.Bots.CourseCommands do
  alias Pillbox.Bots.ReplyCommands
  alias Pillbox.Courses.Courses
  alias Pillbox.Helpers

  def start_create_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id
    } = assigns

    ReplyCommands.answer_callback_query(callback_query_id, token)
    ReplyCommands.reply_for_create_course(chat_id, message_id, token)
    {:ok, Map.merge(state, %{action: "create_course", step: "pill_name"})}
  end

  def create_course(_assigns, %{step: "confirmation"} = state) do
    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  def create_course(assigns, state) do
    %{step: step, bot_message_id: bot_message_id} = state

    %{chat_id: chat_id, message_text: message_text, message_id: message_id, token: token} =
      assigns

    ReplyCommands.delete_message(chat_id, message_id, token)

    case ReplyCommands.cast_input(step, message_text) do
      {:ok, casted_data} ->
        course = ReplyCommands.put_casted_data_to_course_attrs(state, step, casted_data)
        next_step = ReplyCommands.get_next_step(step)

        ReplyCommands.reply_with_next_step_message(
          chat_id,
          bot_message_id,
          next_step,
          course,
          token
        )

        {:ok, Map.merge(state, %{step: next_step, course: course})}

      {:error, reason} ->
        ReplyCommands.reply_with_message(chat_id, bot_message_id, reason, token)
        {:ok, state}
    end
  end

  def list_courses(assigns, state) do
    %{
      telegram_id: telegram_id,
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id
    } = assigns

    ReplyCommands.answer_callback_query(callback_query_id, token)

    courses = Courses.list_courses_for_telegram_user(telegram_id)

    ReplyCommands.reply_with_courses(chat_id, message_id, token, courses)

    {:ok, state}
  end

  def show_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id,
      telegram_id: telegram_id
    } = assigns

    case Courses.get_course(course_id) do
      nil ->
        ReplyCommands.answer_callback_query(callback_query_id, token, "Course not found")

        courses = Courses.list_courses_for_telegram_user(telegram_id)
        ReplyCommands.reply_with_courses(chat_id, message_id, token, courses)

      course ->
        ReplyCommands.answer_callback_query(callback_query_id, token)
        ReplyCommands.reply_with_course(chat_id, message_id, token, course)
    end

    {:ok, state}
  end

  def confirm_create_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      telegram_id: telegram_id
    } = assigns

    %{course: course, user_id: user_id} = state

    ReplyCommands.answer_callback_query(callback_query_id, token)

    course
    |> Map.put(:user_id, user_id)
    |> Courses.create_course()
    |> case do
      {:ok, _course} ->
        ReplyCommands.reply_with_success_create_course(chat_id, message_id, token, telegram_id)

      {:error, changeset} ->
        errors = Helpers.traverse_changeset_errors(changeset)

        ReplyCommands.reply_with_failed_create_course(
          chat_id,
          message_id,
          errors,
          token,
          telegram_id
        )
    end

    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  def discard_create_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id
    } = assigns

    %{telegram_id: telegram_id} = state

    ReplyCommands.answer_callback_query(callback_query_id, token)
    ReplyCommands.reply_discard_course_create(chat_id, message_id, token, telegram_id)

    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  def delete_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id,
      course_id: course_id,
      telegram_id: telegram_id
    } = assigns

    with course when not is_nil(course) <- Courses.get_course(course_id),
         {:ok, _deleted_course} <- Courses.delete_course(course) do
      ReplyCommands.answer_callback_query(callback_query_id, token, "Course successfully deleted")
    else
      nil ->
        ReplyCommands.answer_callback_query(callback_query_id, token, "Course not found")

      {:error, _changeset} ->
        ReplyCommands.answer_callback_query(callback_query_id, token, "Failed to delete course")
    end

    courses = Courses.list_courses_for_telegram_user(telegram_id)
    ReplyCommands.reply_with_courses(chat_id, message_id, token, courses)

    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end
end
