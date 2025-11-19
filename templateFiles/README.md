# Template Files

新しい Docker 環境を追加する際の雛形ファイル

## ファイル構成

```
templateFiles/
├── Dockerfile.template              # Dockerfile の雛形
├── env_IMAGENAME_VERSION.template.sh  # 環境変数ファイルの雛形
└── README.md                        # このファイル
```

## 使用方法

### 1. 新しい環境ディレクトリを作成

```bash
# 例: Node.js 20.0.0 環境を作成する場合
mkdir nodejs_20_0_0
cd nodejs_20_0_0
```

### 2. テンプレートファイルをコピー

```bash
# Dockerfile をコピー
cp ../templateFiles/Dockerfile.template ./Dockerfile

# 環境変数ファイルをコピー
cp ../templateFiles/env_IMAGENAME_VERSION.template.sh ./env_nodejs_20_0_0.sh
```

### 3. プレースホルダーを置換

#### Dockerfile のプレースホルダー

| プレースホルダー | 説明 | 例 |
|----------------|------|-----|
| `<BASE_IMAGE>` | ベースイメージ | `node:20.0.0`, `ubuntu:24.04` |
| `<IMAGE_DIGEST>` | イメージのダイジェスト | `sha256:xxxxx` |
| `<IMAGE_TITLE>` | イメージのタイトル | `"Node.js 20.0.0 Development Environment"` |
| `<IMAGE_DESCRIPTION>` | イメージの説明 | `"Node.js 20.0.0 with essential development tools"` |
| `<IMAGE_VERSION>` | イメージのバージョン | `"20.0.0"` |
| `<CREATED_DATE>` | 作成日（ISO 8601形式） | `"2025-11-16T00:00:00Z"` |
| `<PACKAGES>` | インストールするパッケージ（改行と `\` で区切る） | `vim \`<br>`    git \`<br>`    curl` |
| `<MOUNT_TARGET>` | マウント先パス | `/workspace`, `/home/circleci/project` |

#### env_IMAGENAME_VERSION.sh のプレースホルダー

| プレースホルダー | 説明 | 例 |
|----------------|------|-----|
| `<IMAGENAME>` | イメージ名（小文字） | `nodejs`, `ubuntu`, `python` |
| `<VERSION>` | バージョン（ドット区切り） | `20.0.0`, `24.04` |
| `<VERSION_UNDERSCORE>` | バージョン（アンダースコア区切り） | `20_0_0`, `24_04` |
| `<MOUNT_TARGET>` | マウント先パス | `/workspace`, `/home/circleci/project` |

### 4. 置換方法

#### 方法1: sed コマンドで一括置換

```bash
# Dockerfile の置換例（Node.js 20.0.0）
sed -i \
  -e 's|<BASE_IMAGE>|node:20.0.0|g' \
  -e 's|<IMAGE_DIGEST>|sha256:xxxxx|g' \
  -e 's|<IMAGE_TITLE>|Node.js 20.0.0 Development Environment|g' \
  -e 's|<IMAGE_DESCRIPTION>|Node.js 20.0.0 with essential development tools|g' \
  -e 's|<IMAGE_VERSION>|20.0.0|g' \
  -e 's|<CREATED_DATE>|2025-11-16T00:00:00Z|g' \
  -e 's|<PACKAGES>|vim \\\n    git \\\n    curl|g' \
  -e 's|<MOUNT_TARGET>|/workspace|g' \
  Dockerfile

# env ファイルの置換例
sed -i \
  -e 's|<IMAGENAME>|nodejs|g' \
  -e 's|<VERSION>|20.0.0|g' \
  -e 's|<VERSION_UNDERSCORE>|20_0_0|g' \
  -e 's|<MOUNT_TARGET>|/workspace|g' \
  env_nodejs_20_0_0.sh
```

#### 方法2: エディタで手動置換

エディタを開き、プレースホルダーを検索して置換する。

## イメージのダイジェストを取得する方法

```bash
# Docker Hub からダイジェストを取得
docker pull node:20.0.0
docker inspect node:20.0.0 --format='{{index .RepoDigests 0}}'

# 出力例: node@sha256:xxxxx
# → sha256:xxxxx の部分を <IMAGE_DIGEST> に設定
```

## 実装例

### Ubuntu 24.04 の実装

- ディレクトリ: `ubuntu_24.04/`
- ファイル:
  - `Dockerfile`
  - `env_ubuntu_24_04.sh`

### OpenJDK 21.0.9 の実装

- ディレクトリ: `openjdk_21.0.9/`
- ファイル:
  - `Dockerfile`
  - `env_openjdk_21_0_9.sh`

## テンプレートの特徴

### 既存ユーザー保持方式

テンプレートは、ベースイメージの既存ユーザーを削除せず、UID 衝突時に既存ユーザーの UID を移動する方式を採用

**利点**:
- ベースイメージの初期設定を保持
- ホストとの UID/GID を一致させる
- `--non-unique` を使用しない（セキュリティベストプラクティス）
- ベースイメージへの影響を最小化

**動作**:
1. GID 衝突時：既存グループを再利用
2. UID 衝突時：既存ユーザーの UID を移動し、`devuser` にホスト UID を割り当て
3. 所有ファイルの UID を更新

### ビルド時の UID/GID 指定

```bash
# ホストの UID/GID を指定してビルド
docker build \
  --build-arg BUILD_UID=$(id -u) \
  --build-arg BUILD_GID=$(id -g) \
  -t myimage:latest .
```

共通スクリプト（`Common/00_dockerBuild.sh`）を使用する場合は、自動的にホストの UID/GID を渡す

## 命名規則

### ディレクトリ名

`<環境名>_<バージョン_アンダースコア区切り>/`

例:
- `ubuntu_24_04/`
- `nodejs_20_0_0/`
- `python_3_11_0/`

### ファイル名

- `Dockerfile`（固定）
- `env_<環境名>_<バージョン_アンダースコア区切り>.sh`

例:
- `env_ubuntu_24_04.sh`
- `env_nodejs_20_0_0.sh`
- `env_python_3_11_0.sh`

### Docker リソース名

- **イメージ名**: `<環境名>_<バージョン_アンダースコア区切り>:latest`
- **コンテナ名**: `<環境名>_<バージョン_アンダースコア区切り>_container`

例:
- イメージ: `ubuntu_24_04:latest`
- コンテナ: `ubuntu_24_04_container`

## 関連ドキュメント

- プロジェクトルートの `CLAUDE.md`: プロジェクト全体の説明
- プロジェクトルートの `README.md`: 使用方法とコマンド
- `dev_diary/`: 開発日誌（実装の詳細と学び）
