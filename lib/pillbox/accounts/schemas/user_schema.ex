defmodule Pillbox.Accounts.UserSchema do
  @doc """
    User's schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pillbox.Courses.CourseSchema

  schema "users" do
    field :telegram_id, :integer

    has_many :courses, CourseSchema, foreign_key: :user_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:telegram_id])
    |> validate_required([:telegram_id])
    |> unique_constraint([:telegram_id])
  end
end
