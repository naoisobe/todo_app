defmodule TodoApp.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :is_default, :boolean, default: false, null: false
      add :color, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:name])

    alter table(:todos) do
      add :category_id, references(:categories, on_delete: :nothing)
    end

    create index(:todos, [:category_id])
  end
end
