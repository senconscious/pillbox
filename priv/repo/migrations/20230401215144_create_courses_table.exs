defmodule Pillbox.Repo.Migrations.CreateCoursesTable do
  use Ecto.Migration

  def change do
    create table("courses") do
      add :pill_name, :string, null: false
      add :active?, :boolean, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false

      add :user_id, references("users", on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
