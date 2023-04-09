defmodule Pillbox.Courses.Schemas.Checkin do
  @moduledoc """
    Checkin Schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Courses.Schemas.Timetable

  schema "checkins" do
    field :checked?, :boolean, default: false

    belongs_to :timetable, Timetable

    timestamps()
  end

  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:checked?, :timetable_id])
    |> validate_required([:checked?, :timetable_id])
    |> assoc_constraint(:timetable)
  end
end
