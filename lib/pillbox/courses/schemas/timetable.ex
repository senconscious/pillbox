defmodule Pillbox.Courses.Schemas.Timetable do
  @moduledoc """
    Timetable Schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Courses.Schemas.Course
  alias Pillbox.Courses.Schemas.Checkin

  schema "timetables" do
    field :pill_time, :time
    field :pill_intake_description, :string

    belongs_to :course, Course

    has_many :checkins, Checkin

    timestamps()
  end

  def changeset(timetable, attrs) do
    timetable
    |> cast(attrs, [:pill_time, :pill_intake_description, :course_id])
    |> validate_required([:pill_time, :course_id])
    |> assoc_constraint(:course)
  end
end
