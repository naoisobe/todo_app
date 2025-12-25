defmodule TodoAppWeb.TodoLive do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:sort_by, :inserted_at)
      |> assign(:sort_dir, :desc)
      |> assign(:filter_category_id, nil)
      |> assign(:show_category_mgmt, false)
      |> assign(:categories, Todos.list_categories())
      |> stream(:todos, Todos.list_todos(sort_by: :inserted_at, sort_dir: :desc))

    {:ok, socket}
  end

  def handle_event("save", %{"title" => title, "category_id" => category_id, "priority" => priority, "due_date" => due_date}, socket) do
    due_date = if due_date == "", do: nil, else: due_date

    case Todos.create_todo(%{title: title, done: false, category_id: category_id, priority: priority, due_date: due_date}) do
      {:ok, todo} ->
        {:noreply, stream_insert(socket, :todos, todo, at: 0)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "タスクの作成に失敗しました")}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, todo} = Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  def handle_event("update_title", %{"id" => id, "title" => title}, socket) do
    todo = Todos.get_todo!(id)

    case Todos.update_todo(todo, %{title: title}) do
      {:ok, todo} ->
        {:noreply, stream_insert(socket, :todos, todo)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "更新に失敗しました")}
    end
  end

  def handle_event("update_category", %{"id" => id, "category_id" => category_id}, socket) do
    todo = Todos.get_todo!(id)

    case Todos.update_todo(todo, %{category_id: category_id}) do
      {:ok, todo} ->
        {:noreply, stream_insert(socket, :todos, todo)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "カテゴリの更新に失敗しました")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)
    {:noreply, stream_delete(socket, :todos, todo)}
  end

  def handle_event("sort", %{"by" => by}, socket) do
    by = String.to_existing_atom(by)

    {new_dir, new_socket} =
      if socket.assigns.sort_by == by do
        dir = if socket.assigns.sort_dir == :asc, do: :desc, else: :asc
        {dir, assign(socket, :sort_dir, dir)}
      else
        {:asc, socket |> assign(:sort_by, by) |> assign(:sort_dir, :asc)}
      end

    opts = [sort_by: by, sort_dir: new_dir, category_id: socket.assigns.filter_category_id]
    {:noreply, stream(new_socket, :todos, Todos.list_todos(opts), reset: true)}
  end

  def handle_event("filter_category", %{"id" => id}, socket) do
    id = if id == "", do: nil, else: String.to_integer(id)
    socket = assign(socket, :filter_category_id, id)
    opts = [sort_by: socket.assigns.sort_by, sort_dir: socket.assigns.sort_dir, category_id: id]
    {:noreply, stream(socket, :todos, Todos.list_todos(opts), reset: true)}
  end

  def handle_event("toggle_category_mgmt", _, socket) do
    {:noreply, assign(socket, :show_category_mgmt, !socket.assigns.show_category_mgmt)}
  end

  def handle_event("save_category", %{"name" => name, "color" => color}, socket) do
    case Todos.create_category(%{name: name, color: color}) do
      {:ok, _category} ->
        {:noreply, assign(socket, :categories, Todos.list_categories())}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "カテゴリの作成に失敗しました")}
    end
  end

  def handle_event("delete_category", %{"id" => id}, socket) do
    category = Todos.get_category!(id)

    case Todos.delete_category(category) do
      {:ok, _} ->
        # Refresh categories and todos (since some todos might have moved to "その他")
        socket = assign(socket, :categories, Todos.list_categories())
        opts = [sort_by: socket.assigns.sort_by, sort_dir: socket.assigns.sort_dir, category_id: socket.assigns.filter_category_id]
        {:noreply, stream(socket, :todos, Todos.list_todos(opts), reset: true)}

      {:error, msg} ->
        {:noreply, put_flash(socket, :error, msg)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl px-4 py-8 sm:px-6 lg:px-8">
      <div class="mb-10 flex flex-wrap justify-between items-end gap-4">
        <.header>
          <span class="text-3xl font-bold text-base-content/90">マイ TODO</span>
          <:subtitle>
            <span class="text-base font-normal text-base-content/60">タスクを効率的に管理しましょう</span>
          </:subtitle>
        </.header>

        <div class="flex flex-wrap gap-2 items-center">
          <!-- Filter -->
          <div class="form-control">
            <select class="select select-sm select-bordered" phx-change="filter_category">
              <option value="">すべて表示</option>
              <option :for={cat <- @categories} value={cat.id} selected={@filter_category_id == cat.id}>
                {cat.name}
              </option>
            </select>
          </div>

          <!-- Sorting -->
          <div class="join">
            <button
              phx-click="sort"
              phx-value-by="title"
              class={["btn btn-sm join-item", @sort_by == :title && "btn-primary"]}
            >
              名前
              <.icon :if={@sort_by == :title} name={if @sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"} class="size-3" />
            </button>
            <button
              phx-click="sort"
              phx-value-by="priority"
              class={["btn btn-sm join-item", @sort_by == :priority && "btn-primary"]}
            >
              優先度
              <.icon :if={@sort_by == :priority} name={if @sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"} class="size-3" />
            </button>
            <button
              phx-click="sort"
              phx-value-by="due_date"
              class={["btn btn-sm join-item", @sort_by == :due_date && "btn-primary"]}
            >
              期限
              <.icon :if={@sort_by == :due_date} name={if @sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"} class="size-3" />
            </button>
            <button
              phx-click="sort"
              phx-value-by="category"
              class={["btn btn-sm join-item", @sort_by == :category && "btn-primary"]}
            >
              カテゴリ
              <.icon :if={@sort_by == :category} name={if @sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"} class="size-3" />
            </button>
          </div>

          <!-- Category Management Toggle -->
          <button phx-click="toggle_category_mgmt" class="btn btn-sm btn-ghost">
            <.icon name="hero-cog-6-tooth" class="size-4 mr-1" />
            カテゴリ管理
          </button>
        </div>
      </div>

      <!-- Category Management Section -->
      <div :if={@show_category_mgmt} class="card bg-base-200 shadow-inner mb-10 border border-base-300">
        <div class="card-body p-6">
          <h3 class="font-bold text-lg mb-4 flex items-center">
            <.icon name="hero-tag" class="size-5 mr-2" />
            カテゴリ管理
          </h3>
          
          <div class="flex flex-wrap gap-4 items-start">
            <!-- Add Category Form -->
            <form phx-submit="save_category" class="flex gap-2">
              <input type="text" name="name" placeholder="新しいカテゴリ" class="input input-sm input-bordered w-32" required />
              <input type="color" name="color" value="#6b7280" class="input input-sm p-1 w-10 cursor-pointer" />
              <button type="submit" class="btn btn-sm btn-primary">追加</button>
            </form>

            <div class="divider divider-horizontal hidden sm:flex"></div>

            <!-- Category List -->
            <div class="flex flex-wrap gap-2">
              <div :for={cat <- @categories} class="badge badge-lg gap-2 p-4 h-auto border-2 transition-all hover:pr-1" style={"border-color: #{cat.color}; background-color: #{cat.color}20; color: #{cat.color}"}>
                <span class="font-medium">{cat.name}</span>
                <button
                  :if={!cat.is_default}
                  phx-click="delete_category"
                  phx-value-id={cat.id}
                  class="btn btn-ghost btn-xs btn-circle hover:bg-black/10 p-0"
                >
                  <.icon name="hero-x-mark" class="size-3" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Add New Todo Form -->
      <div class="card bg-base-100 shadow-lg border border-base-200 mb-12 overflow-visible">
        <div class="card-body p-6">
          <form phx-submit="save" class="flex flex-wrap gap-4 items-end">
            <div class="flex-[3] form-control min-w-[200px]">
              <label class="label px-0 pt-0">
                <span class="label-text font-bold text-lg mb-1">新しいタスク</span>
              </label>
              <input
                type="text"
                name="title"
                placeholder="例: 牛乳を買う"
                class="input input-bordered input-lg w-full focus:input-primary shadow-sm"
                required
                autocomplete="off"
              />
            </div>
            <div class="flex-1 form-control min-w-[120px]">
              <label class="label px-0 pt-0">
                <span class="label-text font-bold text-lg mb-1">優先度</span>
              </label>
              <select name="priority" class="select select-bordered select-lg w-full focus:select-primary shadow-sm">
                <option value="low">低</option>
                <option value="medium" selected>中</option>
                <option value="high">高</option>
              </select>
            </div>
            <div class="flex-1 form-control min-w-[150px]">
              <label class="label px-0 pt-0">
                <span class="label-text font-bold text-lg mb-1">期限</span>
              </label>
              <input type="date" name="due_date" class="input input-bordered input-lg w-full focus:input-primary shadow-sm" />
            </div>
            <div class="flex-1 form-control min-w-[150px]">
              <label class="label px-0 pt-0">
                <span class="label-text font-bold text-lg mb-1">カテゴリ</span>
              </label>
              <select name="category_id" class="select select-bordered select-lg w-full focus:select-primary shadow-sm">
                <option :for={cat <- @categories} value={cat.id} selected={cat.name == "その他"}>
                  {cat.name}
                </option>
              </select>
            </div>
            <button type="submit" class="btn btn-primary btn-lg shadow-md min-w-[100px]">
              <.icon name="hero-plus-circle" class="size-6 mr-1" />
              追加
            </button>
          </form>
        </div>
      </div>

      <!-- Todo List -->
      <div class="space-y-4" id="todos" phx-update="stream">
        <div
          :for={{dom_id, todo} <- @streams.todos}
          id={dom_id}
          class="group card bg-base-100 shadow-sm hover:shadow-md transition-all duration-200 border border-transparent hover:border-base-200"
        >
          <div class="card-body p-5">
            <div class="flex items-center gap-5">
              <!-- Checkbox -->
              <input
                type="checkbox"
                phx-click="toggle"
                phx-value-id={todo.id}
                checked={todo.done}
                class="checkbox checkbox-primary checkbox-lg border-2"
              />

              <!-- Content Area -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-3 mb-1">
                  <!-- Category (Editable) -->
                  <div
                    :if={todo.category}
                    class="badge badge-sm font-bold cursor-pointer transition-opacity hover:opacity-80"
                    style={"background-color: #{todo.category.color}20; border-color: #{todo.category.color}; color: #{todo.category.color}"}
                    id={"#{dom_id}-cat-view"}
                    phx-click={JS.add_class("hidden", to: "##{dom_id}-cat-view") |> JS.remove_class("hidden", to: "##{dom_id}-cat-edit") |> JS.focus(to: "##{dom_id}-cat-select")}
                  >
                    {todo.category.name}
                  </div>
                  <div :if={!todo.category} class="badge badge-sm badge-ghost" id={"#{dom_id}-cat-view"}>
                    未設定
                  </div>
                  <div class="hidden" id={"#{dom_id}-cat-edit"}>
                    <form phx-change="update_category" phx-value-id={todo.id}>
                      <select
                        name="category_id"
                        id={"#{dom_id}-cat-select"}
                        class="select select-bordered select-xs"
                        phx-blur={JS.add_class("hidden", to: "##{dom_id}-cat-edit") |> JS.remove_class("hidden", to: "##{dom_id}-cat-view")}
                      >
                        <option :for={cat <- @categories} value={cat.id} selected={cat.id == todo.category_id}>
                          {cat.name}
                        </option>
                      </select>
                    </form>
                  </div>

                  <!-- Options (Priority, Dates) -->
                  <div class="text-[10px] text-base-content/40 flex flex-wrap gap-x-3 gap-y-1">
                    <!-- Priority Badge -->
                    <span class={[
                      "font-bold uppercase tracking-wider px-1 rounded-sm",
                      todo.priority == "high" && "bg-error/10 text-error",
                      todo.priority == "medium" && "bg-warning/10 text-warning-content",
                      todo.priority == "low" && "bg-info/10 text-info"
                    ]}>
                      {case todo.priority do
                        "high" -> "高"
                        "medium" -> "中"
                        "low" -> "低"
                        _ -> todo.priority
                      end}
                    </span>

                    <span :if={todo.due_date} class="flex items-center gap-1 font-medium text-base-content/60">
                      <.icon name="hero-calendar" class="size-3" />
                      期限: {todo.due_date}
                    </span>

                    <span>作成: {format_date(todo.inserted_at)}</span>
                    <span :if={todo.inserted_at != todo.updated_at}>
                      更新: {format_date(todo.updated_at)}
                    </span>
                  </div>
                </div>

                <!-- Title (Editable) -->
                <div id={"#{dom_id}-view"}>
                  <span
                    class={[
                      "text-xl font-medium cursor-pointer hover:text-primary transition-colors block",
                      todo.done && "line-through text-base-content/30"
                    ]}
                    phx-click={JS.add_class("hidden", to: "##{dom_id}-view") |> JS.remove_class("hidden", to: "##{dom_id}-edit") |> JS.focus(to: "##{dom_id}-title-input")}
                  >
                    {todo.title}
                  </span>
                </div>

                <!-- Edit Title Form (Hidden by default) -->
                <div class="hidden" id={"#{dom_id}-edit"}>
                  <form phx-submit="update_title" phx-value-id={todo.id} class="flex gap-2">
                    <input
                      type="text"
                      name="title"
                      value={todo.title}
                      id={"#{dom_id}-title-input"}
                      class="input input-bordered input-md flex-1 text-lg"
                      phx-blur={JS.add_class("hidden", to: "##{dom_id}-edit") |> JS.remove_class("hidden", to: "##{dom_id}-view")}
                      required
                    />
                  </form>
                </div>
              </div>

              <!-- Delete Button -->
              <button
                type="button"
                phx-click="delete"
                phx-value-id={todo.id}
                data-confirm="このタスクを削除してもよろしいですか？"
                class="btn btn-ghost btn-circle btn-sm text-base-content/20 hover:text-error hover:bg-error/5 opacity-0 group-hover:opacity-100 transition-all"
                aria-label="削除"
              >
                <.icon name="hero-trash" class="size-5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <%= if Enum.empty?(@streams.todos.inserts) do %>
        <div class="text-center py-20 opacity-50 select-none">
          <.icon name="hero-clipboard-document-list" class="size-24 mx-auto mb-4 text-base-300" />
          <p class="text-xl font-medium text-base-content/50">タスクがありません</p>
          <p class="text-sm mt-2">新しいタスクを追加して一日を始めましょう！</p>
        </div>
      <% end %>
    </div>
    """
  end

  defp format_date(dt) do
    dt
    |> DateTime.shift_zone!("Asia/Tokyo")
    |> Calendar.strftime("%Y/%m/%d %H:%M")
  end
end
