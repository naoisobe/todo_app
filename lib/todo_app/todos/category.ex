defmodule TodoApp.Todos.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :is_default, :boolean, default: false
    field :color, :string

    has_many :todos, TodoApp.Todos.Todo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :is_default, :color])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
