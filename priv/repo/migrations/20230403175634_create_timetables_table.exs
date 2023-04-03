defmodule Pillbox.Repo.Migrations.CreateTimetablesTable do
  use Ecto.Migration

  def change do
    create table("timetables") do
      add :pill_time, :time, null: false
      add :pill_intake_description, :string

      add :course_id, references("courses", on_delete: :delete_all), null: false

      timestamps()
    end

    create index("timetables", [:course_id, :id])
  end
end
