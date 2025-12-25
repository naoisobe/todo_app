defmodule TodoApp.TodosTest do
  use TodoApp.DataCase

  alias TodoApp.Todos

  describe "todos" do
    alias TodoApp.Todos.Todo

    import TodoApp.TodosFixtures

    @invalid_attrs %{done: nil, title: nil, category_id: nil}

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Todos.list_todos() == [todo]
    end

    test "list_todos/1 returns sorted/filtered todos" do
      cat_a = Repo.insert!(%TodoApp.Todos.Category{name: "A"})
      cat_b = Repo.insert!(%TodoApp.Todos.Category{name: "B"})
      
      todo1 = todo_fixture(title: "X", category_id: cat_b.id)
      todo2 = todo_fixture(title: "Y", category_id: cat_a.id)

      assert Todos.list_todos(sort_by: :title, sort_dir: :asc) == [todo1, todo2]
      assert Todos.list_todos(sort_by: :category, sort_dir: :asc) == [todo2, todo1]
      assert Todos.list_todos(category_id: cat_a.id) == [todo2]
    end

    test "create_todo/1 with valid data creates a todo" do
      cat = Repo.insert!(%TodoApp.Todos.Category{name: "Test"})
      valid_attrs = %{done: true, title: "some title", category_id: cat.id}

      assert {:ok, %Todo{} = todo} = Todos.create_todo(valid_attrs)
      assert todo.done == true
      assert todo.title == "some title"
      assert todo.category_id == cat.id
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{done: false, title: "some updated title"}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, update_attrs)
      assert todo.done == false
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end
  end
end
