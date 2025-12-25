defmodule TodoApp.Repo.Migrations.AddCategoryToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :category, :string, default: "デフォルト"
    end
  end
end
