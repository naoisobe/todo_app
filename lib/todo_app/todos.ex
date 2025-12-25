defmodule TodoApp.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoApp.Repo

  alias TodoApp.Todos.Todo
  alias TodoApp.Todos.Category

  def list_todos(opts \\ []) do
    sort_by = Keyword.get(opts, :sort_by, :inserted_at)
    sort_dir = Keyword.get(opts, :sort_dir, :desc)
    category_id = Keyword.get(opts, :category_id)

    query = 
      if category_id do
        from(t in Todo, where: t.category_id == ^category_id)
      else
        Todo
      end

    query =
      case sort_by do
        :category ->
          from(t in query,
            left_join: c in assoc(t, :category),
            order_by: [{^sort_dir, c.name}]
          )
        _ ->
          from(t in query, order_by: [{^sort_dir, field(t, ^sort_by)}])
      end

    query
    |> preload([:category])
    |> Repo.all()
  end

  def get_todo!(id) do
    Todo
    |> preload([:category])
    |> Repo.get!(id)
  end

  def create_todo(attrs) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, todo} -> {:ok, Repo.preload(todo, :category)}
      error -> error
    end
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, todo} -> {:ok, Repo.preload(todo, :category)}
      error -> error
    end
  end

  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  # Category Functions

  def list_categories do
    Category
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def get_default_category do
    Repo.get_by(Category, name: "その他")
  end

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    if category.is_default do
      {:error, "デフォルトカテゴリは削除できません"}
    else
      # Move todos to "その他"
      default_cat = get_default_category() || Repo.insert!(%Category{name: "その他", is_default: true})
      
      from(t in Todo, where: t.category_id == ^category.id)
      |> Repo.update_all(set: [category_id: default_cat.id, updated_at: DateTime.utc_now()])

      Repo.delete(category)
    end
  end
end
