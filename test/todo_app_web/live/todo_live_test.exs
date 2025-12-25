defmodule TodoAppWeb.TodoLiveTest do
  use TodoAppWeb.ConnCase
  import Phoenix.LiveViewTest
  import TodoApp.TodosFixtures

  describe "Todo Live" do
    setup do
      cat = TodoApp.Todos.get_default_category() || 
            TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "その他", is_default: true})
      %{default_category: cat}
    end

    test "lists all todos and creates new one", %{conn: conn, default_category: cat} do
      {:ok, view, html} = live(conn, ~p"/todos")
      
      assert html =~ "マイ TODO"
      assert html =~ "カテゴリ管理"

      assert view
             |> form("form[phx-submit=save]", title: "新タスク", category_id: cat.id, priority: "high", due_date: "2025-12-31")
             |> render_submit() =~ "新タスク"

      assert render(view) =~ "高"
      assert render(view) =~ "期限: 2025-12-31"
    end

    test "manages categories", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/todos")

      # Open management
      view |> element("button", "カテゴリ管理") |> render_click()

      # Add category
      view |> form("form[phx-submit=save_category]", name: "テスト用", color: "#ff0000") |> render_submit()
      
      assert view |> render() =~ "テスト用"
      
      cat = TodoApp.Repo.get_by!(TodoApp.Todos.Category, name: "テスト用")
      
      # Delete category
      view |> element("button[phx-click=delete_category][phx-value-id='#{cat.id}']") |> render_click()
      refute view |> render() =~ "テスト用"
    end

    test "filters todos by category", %{conn: conn} do
      cat = TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "限定"})
      todo_fixture(title: "見せる", category_id: cat.id)
      todo_fixture(title: "隠す")

      {:ok, view, _html} = live(conn, ~p"/todos")
      
      # Filter
      view |> element("select[phx-change=filter_category]") |> render_change(%{id: cat.id})
      
      assert view |> render() =~ "見せる"
      refute view |> render() =~ "隠す"
    end

    test "toggles todo done state", %{conn: conn} do
      todo = todo_fixture(done: false)
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view |> element("input[type=checkbox][phx-value-id='#{todo.id}']") |> render_click()
      assert TodoApp.Todos.get_todo!(todo.id).done == true
    end

    test "updates todo title", %{conn: conn} do
      todo = todo_fixture()
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view
             |> form("#todos-#{todo.id}-edit form", title: "更新済み")
             |> render_submit() =~ "更新済み"
      
      assert TodoApp.Todos.get_todo!(todo.id).title == "更新済み"
    end

    test "updates todo category", %{conn: conn} do
      cat_new = TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "移動先"})
      todo = todo_fixture()
      {:ok, view, _html} = live(conn, ~p"/todos")

      # We can just target the form even if it's hidden by JS
      view |> form("#todos-#{todo.id}-cat-edit form") |> render_change(%{category_id: cat_new.id})
      
      assert TodoApp.Todos.get_todo!(todo.id).category_id == cat_new.id
    end

    test "sorts todos", %{conn: conn} do
      cat_a = TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "A"})
      cat_b = TodoApp.Repo.insert!(%TodoApp.Todos.Category{name: "B"})
      
      # Using specific priorities and dates to test sorting
      todo_fixture(title: "Y", category_id: cat_a.id, priority: "high", due_date: ~D[2025-12-20])
      todo_fixture(title: "X", category_id: cat_b.id, priority: "low", due_date: ~D[2025-12-10])
      
      {:ok, view, _html} = live(conn, ~p"/todos")

      # Initial sort (inserted_at desc) -> X then Y
      assert view |> render() =~ ~r/X.*Y/s

      # Sort by title (asc) -> X then Y
      view |> element("button[phx-click=sort][phx-value-by=title]") |> render_click()
      assert view |> render() =~ ~r/X.*Y/s

      # Sort by priority (asc) -> high (H) before low (L) alphabet
      view |> element("button[phx-click=sort][phx-value-by=priority]") |> render_click()
      assert view |> render() =~ ~r/Y.*X/s

      # Sort by due_date (asc) -> 12/10 before 12/20
      view |> element("button[phx-click=sort][phx-value-by=due_date]") |> render_click()
      assert view |> render() =~ ~r/X.*Y/s

      # Sort by category (asc) -> Y (cat A) then X (cat B)
      view |> element("button[phx-click=sort][phx-value-by=category]") |> render_click()
      assert view |> render() =~ ~r/Y.*X/s
    end

    test "deletes todo", %{conn: conn} do
      todo = todo_fixture()
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view |> element("button[phx-click=delete][phx-value-id='#{todo.id}']") |> render_click()
      refute view |> has_element?("#todos-#{todo.id}")
      assert_raise Ecto.NoResultsError, fn -> TodoApp.Todos.get_todo!(todo.id) end
    end
  end
end
