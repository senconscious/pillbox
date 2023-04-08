defmodule Pillbox.Courses.CheckinQueries do
  import Ecto.Query

  alias Pillbox.Courses.CheckinSchema
  alias Pillbox.Repo

  def list_pending_checkins_for_telegram_user(telegram_id) do
    CheckinSchema
    |> where([ci], not ci.checked?)
    |> join(:inner, [ci], t in assoc(ci, :timetable), as: :timetable)
    |> join(:inner, [timetable: t], c in assoc(t, :course), as: :course)
    |> join(:inner, [course: c], u in assoc(c, :user),
      as: :user,
      on: u.telegram_id == ^telegram_id
    )
    |> select([ci], map(ci, [:id]))
    |> select_merge([course: c], map(c, [:pill_name]))
    |> Repo.all()
  end

  def get_checkin(id) do
    Repo.get(CheckinSchema, id)
  end
end
