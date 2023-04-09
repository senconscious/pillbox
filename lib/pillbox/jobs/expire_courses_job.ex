defmodule Pillbox.Jobs.ExpireCoursesJob do
  alias Pillbox.Courses.Courses

  def perform do
    Courses.expire_courses()
  end
end
