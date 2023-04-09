defmodule Pillbox.Courses.Schemas.Course do
  @moduledoc """
    Course Schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Accounts.Schemas.User
  alias Pillbox.Courses.Schemas.Timetable

  @required [:pill_name, :start_date, :end_date, :user_id]

  schema "courses" do
    field :pill_name, :string
    field :active?, :boolean
    field :start_date, :date
    field :end_date, :date

    has_many :timetables, Timetable

    belongs_to :user, User

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
    start_date = get_field(changeset, :start_date)

    if Date.compare(start_date, today) != :gt and Date.compare(end_date, today) != :lt do
      put_change(changeset, :active?, true)
    else
      put_change(changeset, :active?, false)
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
