defmodule Pillbox.Repo.Migrations.CreateCheckinsTable do
  use Ecto.Migration

  def change do
    create table("checkins") do
      add :checked?, :boolean, null: false

      add :timetable_id, references("timetables", on_delete: :delete_all), null: false

      timestamps()
    end

    create index("checkins", [:timetable_id, :id])
  end
end
