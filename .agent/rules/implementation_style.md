# 実装スタイルのルール（経験者向け）

ユーザーは Rails や Symfony 等の Web フレームワーク経験者（Elixir/Phoenix は学習中）である。
説明の重複を避け、効率的かつ専門的な対話を行うこと。

1. **技術用語のマッピング**:
   - Phoenix 特有の構造を説明する際は、Rails (ActiveRecord, Controller) や Symfony (Entity, Service) の概念に例えて簡潔に説明する。
   - 基礎的な Web 開発用語（MVC, Migration, SQL 等）の解説は不要。

2. **事前説明のフォーマット**:
   - 実装前に「修正対象ファイル」と「Rails/Symfony との対比を入れた設計意図」を箇条書きで示す。
   - 実行するコマンド（例: `mix ecto.gen.migration`）が、どのレイヤー（DB, Schema 等）に影響するかを明示する。

3. **Context パターンの強調**:
   - Phoenix 推奨の「Context (Domain logic)」と「Web (UI logic)」の分離を意識した設計を提案する。

4. **承認フロー**:
   - 設計意図とファイル構成の提案後、ユーザーの同意を得てから実装を開始する。
   - 提案の最後に必ず「この内容で進めてよろしいでしょうか？」等の確認を含める。
