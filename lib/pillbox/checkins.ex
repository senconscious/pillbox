defmodule Pillbox.Checkins do
  @moduledoc """
    Checkins API
  """

  import Ecto.Query,
    only: [
      where: 3,
      join: 5,
      select: 3,
      select_merge: 3
    ]

  alias Pillbox.Courses.Checkin
  alias Pillbox.Repo

  def create_checkin(timetable_id) do
    %Checkin{}
    |> Checkin.changeset(%{timetable_id: timetable_id})
    |> Repo.insert()
  end

  def update_checkin(checkin, attrs) do
    checkin
    |> Checkin.changeset(attrs)
    |> Repo.update()
  end

  def list_pending_checkins_for_telegram_user(telegram_id) do
    Checkin
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
    Repo.get(Checkin, id)
  end
end
