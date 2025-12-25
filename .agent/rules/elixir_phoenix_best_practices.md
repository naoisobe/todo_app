# Elixir & Phoenix ベストプラクティス・規約

このプロジェクトでは、Elixir公式、Phoenix公式（Hexdocs）、およびコミュニティのスタイルガイド（Christopher Adams版）に基づいた実装を行います。

## 1. Elixir コーディングスタイル
- **命名規則**: 
  - 変数・関数名: `snake_case`
  - モジュール名: `PascalCase`
  - 真偽値を返す関数: `?` で終わらせる（例: `done?`）
- **パイプ演算子 (`|>`)**:
  - データの変換フローが明確になるように使用する。
  - 最初の引数として値を渡し、多段に繋げるスタイルを推奨。
- **ドキュメント**:
  - モジュールには必ず `@moduledoc` を含め、役割を簡潔に説明する。

## 2. Phoenix 構造設計 (Contexts)
- **分離の原則**: 
  - 「ビジネスロジック・DB操作」は `lib/todo_app/` 以下の **Context モジュール** に記述する。
  - 「表示・UIイベント」は `lib/todo_app_web/` 以下の **LiveView/Controller** に記述する。
- **Skinny LiveView**:
  - LiveView 内で直接 `Repo` (データベース操作) を呼び出さない。必ず Context 経由で行う。
- **Schema & Changeset**:
  - データのバリデーションや変換ロジックは、`lib/todo_app/todos/todo.ex` 等の Schema 内の `changeset/2` 関数に集約する。

## 3. Phoenix LiveView 実装
- **データの扱い**: 大量または動的なリストの表示には `stream/3` を使用し、クライアント側のメモリ消費を抑える。
- **イベントハンドリング**: `handle_event/3` は短く保ち、複雑な処理は Context へ委譲する。

## 4. コード例 (ベストプラクティス)

### パイプ演算子の良い例:
```elixir
# 明快なフロー
todos
|> Enum.filter(&(&1.priority == :high))
|> Enum.sort_by(&(&1.inserted_at), {:desc, DateTime})
```

### Context の良い例:
```elixir
# lib/todo_app_web/live/todo_live.ex (UI側)
def handle_event("delete", %{"id" => id}, socket) do
  todo = Todos.get_todo!(id)
  {:ok, _} = Todos.delete_todo(todo) # ロジックは Todos context に任せる
  {:noreply, stream_delete(socket, :todos, todo)}
end
```
