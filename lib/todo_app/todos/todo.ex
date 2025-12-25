defmodule TodoApp.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :done, :boolean, default: false
    field :priority, :string, default: "medium"
    field :due_date, :date
    belongs_to :category, TodoApp.Todos.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done, :category_id, :priority, :due_date])
    |> validate_required([:title, :done, :category_id, :priority])
    |> validate_inclusion(:priority, ["low", "medium", "high"])
  end
end
