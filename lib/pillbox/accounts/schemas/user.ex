defmodule Pillbox.Accounts.User do
  @doc """
    User's schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :telegram_id, :integer

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:telegram_id])
    |> validate_required([:telegram_id])
    |> unique_constraint([:telegram_id])
  end
end
