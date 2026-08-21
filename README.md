# 夕焼けマルシェ スタンプカードアプリ

LINE LIFF上で動作する、イベント来場者向けデジタルスタンプカードです。来場者はLINEログイン後、会場のNFCタグにスマホをかざすかQRコードから開き、位置情報で会場付近であることを確認した上でチェックインしてスタンプを獲得します。スタンプ数に応じてランクが上がります。スタッフ向けにActiveAdminの管理画面があり、イベント・来場者・ランクの管理や、紙の会員カード発行、手動でのスタンプ付与ができます。

## 主な機能

- **来場者側（`/liff`配下）**
  - LINEログイン（LIFF ID Token検証）
  - NFCタグ1本で「本日開催中のイベント」を自動解決してチェックイン画面へ誘導（`/liff/checkin`）
  - 位置情報による会場付近チェック（会場座標未設定のイベントはチェックをスキップ）
  - マイページ：現在のランク、スタンプ数、来場履歴
- **管理画面（`/admin`、Devise認証）**
  - イベントのCRUD（会場座標・許容半径・公開ステータス管理）
  - 来場者管理、紙カード発行（システムがカード番号を自動採番）
  - 来場者へのスタンプ手動付与（NFCタグ故障時の緊急オーバーライド、紙カード来場者向け）
  - ランク（スタンプ数のしきい値と特典）の管理

## セットアップ

### 必要なもの

- Ruby 3.4.10（`.ruby-version`参照）
- PostgreSQL
- Node.js不要（importmap + Tailwind CLIを使用）

### 手順

```bash
bin/setup
```

上記で依存関係のインストール、データベースの準備（`db:prepare`）、ログ／tmpのクリアまで行い、開発サーバー（`bin/dev`）が起動します。DBを作り直したい場合は `bin/setup --reset` を使ってください。

### Credentials（LINE連携）

LIFFログインとID Token検証には、暗号化されたcredentialsに以下のキーが必要です。

```bash
bin/rails credentials:edit
```

```yaml
line:
  channel_id: <LINEログインチャネルのチャネルID>
  liff_id: <LIFFアプリのLIFF ID>
```

未設定の場合、LIFFログインは失敗します（`app/services/line_id_token_verifier.rb`、`app/views/liff/entry/show.html.erb`）。

### タイムゾーン

アプリ全体のタイムゾーンは `Asia/Tokyo`（`config/application.rb`）です。イベントの`held_on`や「本日開催中のイベント」判定（`liff/checkin_controller.rb`）はJST基準で行われるため、変更しないでください。

## テストの実行

```bash
bin/rails db:test:prepare
bundle exec rspec
```

## Lint / セキュリティスキャン

```bash
bin/rubocop           # スタイルチェック
bin/brakeman           # 静的セキュリティ解析
bin/bundler-audit      # Gemの既知脆弱性チェック
bin/importmap audit    # JS依存の既知脆弱性チェック
```

まとめて実行する場合は `bin/ci`。ただし現状GitHub Actions（`.github/workflows/ci.yml`）はセキュリティスキャンとRuboCopのみを実行しており、`bundle exec rspec` はCIに含まれていません。PRのテストはローカルで実行して確認してください。

## デプロイ

[Kamal](https://kamal-deploy.org/)（`config/deploy.yml`）を使用します。

```bash
bin/kamal setup   # 初回のみ
bin/kamal deploy
```

- `RAILS_MASTER_KEY`（`.kamal/secrets`経由）が必須です。
- SSLをKamalのプロキシで自動終端する構成にする場合は、`config/deploy.yml`の`proxy`をコメントアウト解除し、`config/environments/production.rb`の`config.assume_ssl` / `config.force_ssl`も合わせて有効化してください。
- `config.hosts`（`config/environments/production.rb`）も本番ドメインに合わせて設定することを推奨します。
