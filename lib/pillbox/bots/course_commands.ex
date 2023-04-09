defmodule Pillbox.Bots.CourseCommands do
  alias Pillbox.Courses.Courses

  alias Pillbox.Bots.CommandAPI

  alias Pillbox.Bots.Keyboards
  alias Pillbox.Helpers

  def start_create_course(assigns, state) do
    %{
      chat_id: chat_id,
      message_id: message_id,
      token: token,
      callback_query_id: callback_query_id
    } = assigns

    CommandAPI.answer_callback_query(callback_query_id, token)
    reply_for_create_course(chat_id, message_id, token)
    {:ok, Map.merge(state, %{action: "create_course", step: "pill_name"})}
  end

  def create_course(_assigns, %{step: "confirmation"} = state) do
    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  def create_course(assigns, state) do
    %{step: step, bot_message_id: bot_message_id} = state

    %{chat_id: chat_id, message_text: message_text, message_id: message_id, token: token} =
      assigns

    CommandAPI.delete_message(chat_id, message_id, token)

    case cast_input(step, message_text) do
      {:ok, casted_data} ->
        course = put_casted_data_to_course_attrs(state, step, casted_data)
        next_step = get_next_step(step)

        reply_with_next_step_message(
          chat_id,
          bot_message_id,
          next_step,
          course,
          token
        )

        {:ok, Map.merge(state, %{step: next_step, course: course})}

      {:error, reason} ->
        CommandAPI.edit_message(chat_id, bot_message_id, token, reason)
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

    CommandAPI.answer_callback_query(callback_query_id, token)

    courses = Courses.list_courses_for_telegram_user(telegram_id)

    reply_with_courses(chat_id, message_id, token, courses)

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
        CommandAPI.answer_callback_query(callback_query_id, token, "Course not found")

        courses = Courses.list_courses_for_telegram_user(telegram_id)
        reply_with_courses(chat_id, message_id, token, courses)

      course ->
        CommandAPI.answer_callback_query(callback_query_id, token)
        reply_with_course(chat_id, message_id, token, course)
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

    CommandAPI.answer_callback_query(callback_query_id, token)

    course
    |> Map.put(:user_id, user_id)
    |> Courses.create_course()
    |> case do
      {:ok, _course} ->
        reply_with_success_create_course(chat_id, message_id, token, telegram_id)

      {:error, changeset} ->
        errors = Helpers.traverse_changeset_errors(changeset)

        reply_with_failed_create_course(
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

    CommandAPI.answer_callback_query(callback_query_id, token)
    reply_discard_course_create(chat_id, message_id, token, telegram_id)

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
      CommandAPI.answer_callback_query(callback_query_id, token, "Course successfully deleted")
    else
      nil ->
        CommandAPI.answer_callback_query(callback_query_id, token, "Course not found")

      {:error, _changeset} ->
        CommandAPI.answer_callback_query(callback_query_id, token, "Failed to delete course")
    end

    courses = Courses.list_courses_for_telegram_user(telegram_id)
    reply_with_courses(chat_id, message_id, token, courses)

    {:ok, Map.take(state, [:user_id, :bot_message_id])}
  end

  defp reply_with_courses(chat_id, message_id, token, courses) do
    keyboard = Keyboards.build_inline_keyboard(:courses_menu, courses: courses)
    text = "Courses"

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_with_course(chat_id, message_id, token, course) do
    keyboard = Keyboards.build_inline_keyboard(:course_menu, course: course)
    text = build_text_for_show_course(course)

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_for_create_course(chat_id, message_id, token) do
    text = build_text_for_step("pill_name", %{})
    CommandAPI.edit_message(chat_id, message_id, token, text)
  end

  defp reply_discard_course_create(chat_id, message_id, token, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)
    text = "Course not created"

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_with_success_create_course(chat_id, message_id, token, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)
    text = "Successfully created course"

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_with_failed_create_course(chat_id, message_id, errors, token, telegram_id) do
    keyboard = Keyboards.build_inline_keyboard(:main_menu, telegram_id: telegram_id)
    text = build_text_for_failed_create_course(errors)

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp get_next_step(current_step) do
    case current_step do
      "pill_name" -> "start_date"
      "start_date" -> "end_date"
      "end_date" -> "confirmation"
    end
  end

  defp cast_input("pill_name", raw_data) do
    length = String.length(raw_data)

    if length >= 1 and length <= 20 do
      {:ok, raw_data}
    else
      {:error, "Pill name must be no more than 20 symbols length"}
    end
  end

  defp cast_input(step, raw_data) when step in ["start_date", "end_date"] do
    with {:error, :invalid_format} <- Date.from_iso8601(raw_data) do
      {:error, "Date format must be YYYY-MM-DD"}
    end
  end

  defp reply_with_next_step_message(chat_id, message_id, step, course_attrs, token)
       when step == "confirmation" do
    text = build_text_for_step(step, course_attrs)
    keyboard = Keyboards.build_inline_keyboard(:course_confirmation)

    CommandAPI.edit_message(chat_id, message_id, token, text, keyboard)
  end

  defp reply_with_next_step_message(chat_id, message_id, step, course_attrs, token) do
    text = build_text_for_step(step, course_attrs)

    CommandAPI.edit_message(chat_id, message_id, token, text)
  end

  defp put_casted_data_to_course_attrs(%{course: course}, step, data) when is_map(course) do
    key =
      case step do
        "pill_name" -> :pill_name
        "start_date" -> :start_date
        "end_date" -> :end_date
      end

    Map.put(course, key, data)
  end

  defp put_casted_data_to_course_attrs(_state, step, data) do
    put_casted_data_to_course_attrs(%{course: %{}}, step, data)
  end

  def build_text_for_listing_courses(courses) when courses == [] do
    "No courses found"
  end

  def build_text_for_listing_courses(courses) do
    "Found #{Enum.count(courses)} courses"
  end

  def build_text_for_step(step, course_attrs) do
    case step do
      "pill_name" ->
        "Enter pill name"

      "start_date" ->
        "Enter course start date in YYYY-MM-DD format"

      "end_date" ->
        "Enter course end date in YYYY-MM-DD format"

      "confirmation" ->
        "Create course with pill name #{course_attrs.pill_name}, start date #{course_attrs.start_date} and end date #{course_attrs.end_date}"
    end
  end

  def build_text_for_failed_create_course(errors) do
    errors
    |> Enum.map(fn {key, value} ->
      [message | _tail] = value
      "#{Atom.to_string(key)} #{message}"
    end)
    |> Enum.join(", ")
    |> then(fn message -> "Failed to create course: #{message}" end)
  end

  def build_text_for_show_course(course) do
    [:pill_name, :active?, :start_date, :end_date]
    |> Enum.map(fn key -> "#{key}: #{Map.fetch!(course, key)}" end)
    |> Enum.join("\n")
  end
end
