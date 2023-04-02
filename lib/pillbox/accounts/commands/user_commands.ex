defmodule Pillbox.Accounts.UserCommands do
  @doc """
    User's commands
  """

  alias Pillbox.Repo
  alias Pillbox.Accounts.UserSchema

  def insert_user!(attrs) do
    %UserSchema{}
    |> UserSchema.changeset(attrs)
    |> Repo.insert!()
  end
end
