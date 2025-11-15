# temporaryDocker

Docker を使用した開発環境管理プロジェクト

## 概要

このリポジトリは、様々な開発環境を Docker コンテナで構築するためのテンプレートを置き場  
各環境は独立したディレクトリで管理（Dockerfile と環境変数ファイルのみ）  
共通化されたスクリプトにより、簡単に環境の構築・起動・削除が可能  

## 使い方

### 1. イメージのビルド

```bash
# 各環境ディレクトリから実行
cd openjdk_21.0.9
../Common/00_dockerBuild.sh env_openjdk_21_0_9.sh

# またはプロジェクトルートから実行
./Common/00_dockerBuild.sh openjdk_21.0.9/env_openjdk_21_0_9.sh
```

Docker イメージをビルド。初回のみ実行が必要。  
共通化されたスクリプトに環境ファイルを引数として渡す。  

### 2. コンテナの起動

#### 一時コンテナとして起動 (推奨)

```bash
# 各環境ディレクトリから実行
cd openjdk_21.0.9
../Common/01_dockerRunTemporary.sh env_openjdk_21_0_9.sh

# またはプロジェクトルートから実行
./Common/01_dockerRunTemporary.sh openjdk_21.0.9/env_openjdk_21_0_9.sh
```

- 対話型シェルが起動する
- `exit` で終了すると、コンテナは自動的に削除される

#### バックグラウンドで起動

```bash
# 各環境ディレクトリから実行
cd openjdk_21.0.9
../Common/02_dockerRunDetached.sh env_openjdk_21_0_9.sh

# またはプロジェクトルートから実行
./Common/02_dockerRunDetached.sh openjdk_21.0.9/env_openjdk_21_0_9.sh
```

- バックグラウンドでコンテナが起動
- コンテナにアタッチする: `docker exec -it openjdk_21_0_9_container /bin/bash`
- コンテナを停止する: `docker stop openjdk_21_0_9_container`

### 3. クリーンアップ

```bash
# 各環境ディレクトリから実行
cd openjdk_21.0.9
../Common/03_removeDocker.sh env_openjdk_21_0_9.sh

# またはプロジェクトルートから実行
./Common/03_removeDocker.sh openjdk_21.0.9/env_openjdk_21_0_9.sh
```

コンテナの停止、削除、およびイメージの削除を一括で実行

## 新しい環境の追加方法

新しい Docker 環境（例: Node.js, Python など）を追加する場合、以下の手順を参考

### 1. ディレクトリ構造

新しい環境用のディレクトリを作成:

```bash
mkdir <環境名>_<バージョン>
# 例: mkdir nodejs_20.0.0
```

### 2. 必須ファイル（各環境ディレクトリ内）

以下の2つのファイルのみ作成（Docker 操作スクリプトは Common/ に集約されているため不要）:

1. **`Dockerfile`** - ベースイメージと追加パッケージの定義
2. **`env_<環境名>_<バージョン>.sh`** - 環境変数定義ファイル

### 3. 環境変数ファイル (env_*.sh) の作成

以下のテンプレートを使用して、環境変数ファイルを作成:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# 環境の基本情報
readonly ENV_VERSION="<バージョン>"  # 例: "20.0.0"
readonly ENV_BASE_NAME="<環境名>"    # 例: "nodejs"

# Docker リソース名（バージョンはアンダースコア区切り）
readonly ENV_IMAGE_NAME="<環境名>_<バージョン_アンダースコア>:latest"  # 例: "nodejs_20_0_0:latest"
readonly ENV_CONTAINER_NAME="<環境名>_<バージョン_アンダースコア>_container"  # 例: "nodejs_20_0_0_container"

# マウント先パス（ベースイメージのデフォルト作業ディレクトリに合わせる）
readonly ENV_MOUNT_TARGET="<マウント先パス>"  # 例: "/workspace"

# 変数をエクスポート
export ENV_VERSION ENV_BASE_NAME ENV_IMAGE_NAME ENV_CONTAINER_NAME ENV_MOUNT_TARGET

# バージョン変換ヘルパー関数（必要に応じて使用）
version_dot_to_underscore() {
    echo "$1" | tr '.' '_'
}

version_underscore_to_dot() {
    echo "$1" | tr '_' '.'
}
```

### 4. 命名規則

- **ディレクトリ名**: `<環境名>_<バージョン_ドット区切り>/` (例: `nodejs_20.0.0/`)
- **イメージ名**: `<環境名>_<バージョン_アンダースコア区切り>:latest` (例: `nodejs_20_0_0:latest`)
- **コンテナ名**: `<環境名>_<バージョン_アンダースコア区切り>_container` (例: `nodejs_20_0_0_container`)
- **環境ファイル名**: `env_<環境名>_<バージョン_アンダースコア区切り>.sh` (例: `env_nodejs_20_0_0.sh`)

### 5. Dockerfile の作成

ベースイメージの digest を固定し、OCI LABEL を追加

```dockerfile
FROM <ベースイメージ>@sha256:<digest>

# OCI推奨のLABEL
LABEL org.opencontainers.image.title="<環境名>"
LABEL org.opencontainers.image.description="<説明>"
LABEL org.opencontainers.image.version="<バージョン>"
LABEL org.opencontainers.image.created="<作成日時>"

# 必要なパッケージのインストール
USER root
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends <パッケージ> && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 元のユーザーに戻す
USER <元のユーザー>
```

### 6. スクリプトの使用方法

環境を追加したら、Common/ の共通スクリプトを使用:

```bash
# 各環境ディレクトリから実行
cd nodejs_20.0.0
../Common/00_dockerBuild.sh env_nodejs_20_0_0.sh
../Common/01_dockerRunTemporary.sh env_nodejs_20_0_0.sh

# またはプロジェクトルートから実行
./Common/00_dockerBuild.sh nodejs_20.0.0/env_nodejs_20_0_0.sh
./Common/01_dockerRunTemporary.sh nodejs_20.0.0/env_nodejs_20_0_0.sh
```
