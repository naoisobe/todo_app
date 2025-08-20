# README

簡単な Todo アプリを追加しました。Hotwire (Turbo + Stimulus) を利用し、レスポンシブなシンプル UI です。

セットアップ手順:

1. 依存関係をインストール

   ```
   bundle install
   ```

2. データベースを作成してマイグレーションを実行

   ```
   rails db:create db:migrate
   ```

3. サーバーを起動

   ```
   bin/rails server
   ```

Hotwire により非同期で追加・更新・削除が動作します。フロントエンドの Stimulus コントローラは `app/javascript/controllers/todo_controller.js` にあります。

この README は通常、アプリケーションを起動して実行するために必要な手順を文書化します。

カバーする可能性のあること:

* Ruby バージョン

* システム依存関係

* 設定

* データベースの作成

* データベースの初期化

* テストスイートの実行方法

* サービス (ジョブキュー、キャッシュサーバー、検索エンジンなど)

* デプロイメントの手順
