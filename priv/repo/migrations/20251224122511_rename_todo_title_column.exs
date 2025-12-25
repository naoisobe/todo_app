defmodule TodoApp.Repo.Migrations.RenameTodoTitleColumn do
  use Ecto.Migration

  def change do
    rename table(:todos), :" title", to: :title
  end
end
