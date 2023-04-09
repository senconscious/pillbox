defmodule Pillbox.Accounts.Users do
  @moduledoc """
    Users API
  """

  alias Pillbox.Repo
  alias Pillbox.Accounts.Schemas.User

  def get_or_create_user(telegram_id) do
    with nil <- get_user_by(telegram_id: telegram_id) do
      insert_user!(%{telegram_id: telegram_id})
    end
  end

  defp get_user_by(clauses) do
    Repo.get_by(User, clauses)
  end

  defp insert_user!(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end
end
