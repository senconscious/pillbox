defmodule Pillbox.Jobs.ActivateCoursesJob do
  alias Pillbox.Courses.Courses

  def perform do
    Courses.activate_courses()
  end
end
