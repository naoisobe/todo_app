defmodule TodoApp.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoApp.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    category = TodoApp.Todos.get_default_category() || 
               TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "その他", is_default: true})

    {:ok, todo} =
      attrs
      |> Enum.into(%{
         title: "some title",
        done: true,
        category_id: category.id
      })
      |> TodoApp.Todos.create_todo()

    todo
    |> TodoApp.Repo.preload(:category)
  end
end
