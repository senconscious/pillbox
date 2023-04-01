defmodule Pillbox.Accounts.UserQueries do
  @doc """
    User's queries
  """

  alias Pillbox.Repo
  alias Pillbox.Accounts.User

  def get_user_by(clauses) do
    Repo.get_by(User, clauses)
  end
end
