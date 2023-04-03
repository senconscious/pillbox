defmodule Pillbox.Courses.TimetableCommands do
  alias Pillbox.Courses.TimetableSchema
  alias Pillbox.Repo

  def insert_timetable(attrs) do
    %TimetableSchema{}
    |> TimetableSchema.changeset(attrs)
    |> Repo.insert()
  end
end
