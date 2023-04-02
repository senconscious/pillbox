defmodule Pillbox.Courses.CourseCommands do
  @moduledoc """
    Course commands
  """

  alias Pillbox.Repo
  alias Pillbox.Courses.CourseSchema

  def insert_course(attrs) do
    %CourseSchema{}
    |> CourseSchema.changeset(attrs)
    |> Repo.insert()
  end
end
