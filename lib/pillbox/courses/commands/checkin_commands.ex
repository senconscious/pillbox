defmodule Pillbox.Courses.CheckinCommands do
  alias Pillbox.Courses.CheckinSchema
  alias Pillbox.Repo

  def insert_checkin(timetable_id) do
    %CheckinSchema{}
    |> CheckinSchema.changeset(%{timetable_id: timetable_id})
    |> Repo.insert()
  end

  def update_checkin(checkin, attrs) do
    checkin
    |> CheckinSchema.changeset(attrs)
    |> Repo.update()
  end
end
