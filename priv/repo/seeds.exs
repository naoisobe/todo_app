alias TodoApp.Repo
alias TodoApp.Todos.Category

categories = [
  %{name: "仕事", is_default: true, color: "#ef4444"},
  %{name: "プライベート", is_default: true, color: "#3b82f6"},
  %{name: "買い物", is_default: true, color: "#10b981"},
  %{name: "その他", is_default: true, color: "#6b7280"}
]

for cat <- categories do
  unless Repo.get_by(Category, name: cat.name) do
    Repo.insert!(struct(Category, cat))
  end
end
