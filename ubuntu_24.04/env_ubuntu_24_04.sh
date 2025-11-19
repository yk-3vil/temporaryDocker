#!/usr/bin/env bash

# Ubuntu 24.04 環境用の環境変数定義ファイル
#
# 利用方法:
#   source "${PROJECT_ROOT}/ubuntu_24.04/env_ubuntu_24_04.sh"
#
# 概要:
#   このファイルは、Ubuntu 24.04 環境で使用される共通変数を定義
#   各スクリプトでこのファイルを source することで、変数の一元管理を実現

# 厳格モードの設定
set -Eeuo pipefail
IFS=$'\n\t'

# ========================================
# 基本変数
# ========================================

# バージョン（ドット区切り）
readonly ENV_VERSION="24.04"

# ベース名（環境の種類）
readonly ENV_BASE_NAME="ubuntu"

# ========================================
# Docker リソース名（アンダースコア区切り）
# ========================================

# Docker イメージ名
readonly ENV_IMAGE_NAME="ubuntu_24_04:latest"

# Docker コンテナ名
readonly ENV_CONTAINER_NAME="ubuntu_24_04_container"

# ========================================
# マウント設定
# ========================================

# コンテナ内のマウントターゲットパス
readonly ENV_MOUNT_TARGET="/workspace"

# ========================================
# イメージ作成日時（ISO 8601形式）
# ========================================

# 現在時刻をISO 8601形式で取得（UTC）
readonly ENV_CREATED_DATE="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# ========================================
# バージョン変換ヘルパー関数
# ========================================

# ドット区切りをアンダースコア区切りに変換
# 引数: $1 - ドット区切りの文字列 (例: "24.04")
# 戻り値: アンダースコア区切りの文字列 (例: "24_04")
version_dot_to_underscore() {
  local version="$1"
  echo "${version//./_}"
}

# アンダースコア区切りをドット区切りに変換
# 引数: $1 - アンダースコア区切りの文字列 (例: "24_04")
# 戻り値: ドット区切りの文字列 (例: "24.04")
version_underscore_to_dot() {
  local version="$1"
  echo "${version//_/.}"
}

# ========================================
# エクスポート（他のシェルスクリプトで使用可能にする）
# ========================================

export ENV_VERSION
export ENV_BASE_NAME
export ENV_IMAGE_NAME
export ENV_CONTAINER_NAME
export ENV_MOUNT_TARGET
export ENV_CREATED_DATE
