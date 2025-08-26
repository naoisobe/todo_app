# GitHub Secrets設定ガイド

GitHub リポジトリの Settings > Secrets and variables > Actions で以下を設定：

## 必要なSecrets

1. **DOCKER_HUB_PASSWORD**
   - Docker Hubのパスワード（またはPersonal Access Token）
   - 値: `tintinkayui`

2. **RAILS_MASTER_KEY**
   - Rails暗号化のマスターキー
   - 値: config/master.key の内容

3. **SSH_PRIVATE_KEY**
   - VPSアクセス用の秘密鍵
   - 値: ~/.ssh/sakura_vps の内容（BEGIN/END含む）

## 設定手順

1. GitHubリポジトリページを開く
2. Settings タブをクリック
3. 左サイドバーの "Secrets and variables" > "Actions" をクリック
4. "New repository secret" ボタンをクリック
5. 各Secretを一つずつ追加

## セキュリティ注意事項

- 秘密鍵やパスワードは絶対にコードにコミットしない
- GitHub Secretsは暗号化されて保存される
- Actionsログには値が表示されない（***でマスクされる）
