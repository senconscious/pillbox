defmodule Pillbox.Courses.CheckinSchema do
  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Courses.TimetableSchema

  schema "checkins" do
    field :checked?, :boolean, default: false

    belongs_to :timetable, TimetableSchema

    timestamps()
  end

  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:checked?, :timetable_id])
    |> validate_required([:checked?, :timetable_id])
    |> assoc_constraint(:timetable)
  end
end
