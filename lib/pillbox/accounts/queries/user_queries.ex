defmodule Pillbox.Accounts.UserQueries do
  @doc """
    User's queries
  """

  alias Pillbox.Repo
  alias Pillbox.Accounts.UserSchema

  def get_user_by(clauses) do
    Repo.get_by(UserSchema, clauses)
  end
end
