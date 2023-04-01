defmodule Pillbox.Accounts.UserCommands do
  @doc """
    User's commands
  """

  alias Pillbox.Repo
  alias Pillbox.Accounts.User

  def insert_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
