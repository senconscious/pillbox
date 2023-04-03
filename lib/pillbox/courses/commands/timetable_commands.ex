defmodule Pillbox.Courses.TimetableCommands do
  alias Pillbox.Courses.TimetableSchema
  alias Pillbox.Repo

  def insert_timetable(attrs) do
    %TimetableSchema{}
    |> TimetableSchema.changeset(attrs)
    |> Repo.insert()
  end

  def delete_timetable(timetable), do: Repo.delete(timetable)
end
