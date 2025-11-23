#!/usr/bin/env bash

# <IMAGENAME> <VERSION> 環境用の環境変数定義ファイル
#
# 利用方法:
#   source "${PROJECT_ROOT}/<imagename>_<version>/env_<imagename>_<version>.sh"
#
# 概要:
#   このファイルは、<IMAGENAME> <VERSION> 環境で使用される共通変数を定義
#   各スクリプトでこのファイルを source することで、変数の一元管理を実現

# 厳格モードの設定
set -Eeuo pipefail
IFS=$'\n\t'

# ========================================
# 基本変数
# ========================================

# バージョン（ドット区切り）
# 例: "24.04", "21.0.9"
readonly ENV_VERSION="<VERSION>"

# ベース名（環境の種類）
# 例: "ubuntu", "openjdk", "nodejs"
readonly ENV_BASE_NAME="<IMAGENAME>"

# ========================================
# Docker リソース名（バージョンはドット区切り）
# ========================================

# Docker イメージ名
# 例: "ubuntu_24.04:latest", "cimg_openjdk_21.0.9:latest"
readonly ENV_IMAGE_NAME="<IMAGENAME>_<VERSION>:latest"

# Docker コンテナ名
# 例: "ubuntu_24.04_container", "cimg_openjdk_21.0.9_container"
readonly ENV_CONTAINER_NAME="<IMAGENAME>_<VERSION>_container"

# ========================================
# マウント設定
# ========================================

# コンテナ内のマウントターゲットパス
# 例: "/workspace", "/home/circleci/project"
readonly ENV_MOUNT_TARGET="<MOUNT_TARGET>"

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
