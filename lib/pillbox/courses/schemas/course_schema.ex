defmodule Pillbox.Courses.CourseSchema do
  @moduledoc """
    Course Schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Accounts.UserSchema

  @required [:pill_name, :start_date, :end_date, :user_id]

  schema "courses" do
    field :pill_name, :string
    field :active?, :boolean
    field :start_date, :date
    field :end_date, :date

    belongs_to :user, UserSchema

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_datetimes_order()
    |> set_active_flag()
    |> assoc_constraint(:user)
  end

  defp set_active_flag(%{valid?: true} = changeset) do
    today = Date.utc_today()
    end_date = get_field(changeset, :end_date)

    case Date.compare(end_date, today) do
      :lt ->
        put_change(changeset, :active?, false)

      _gt_or_eq ->
        put_change(changeset, :active?, true)
    end
  end

  defp set_active_flag(changeset), do: changeset

  defp validate_datetimes_order(%{valid?: true} = changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if Date.compare(start_date, end_date) == :gt do
      add_error(changeset, :start_date, "Must be sooner than end_date")
    else
      changeset
    end
  end

  defp validate_datetimes_order(changeset), do: changeset
end
