defmodule TodoApp.Repo.Migrations.AddPriorityAndDueDateToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :priority, :string, default: "medium", null: false
      add :due_date, :date
    end
  end
end
