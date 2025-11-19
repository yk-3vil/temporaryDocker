#!/usr/bin/env bash

# Docker コンテナ起動スクリプト（一時コンテナ、共通化版）
# 対話型で起動し、終了時に自動削除される
#
# 使用方法:
#   - 各imageディレクトリから: ../Common/01_dockerRunTemporary.sh env_cimg_openjdk_21_0_9.sh
#   - プロジェクトルートから: ./Common/01_dockerRunTemporary.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh

# ========================================
# 引数チェック
# ========================================

if [[ $# -ne 1 ]]; then
  echo "使用方法: $0 <環境ファイルパス>"
  echo ""
  echo "例（各imageディレクトリから）:"
  echo "  ../Common/01_dockerRunTemporary.sh env_cimg_openjdk_21_0_9.sh"
  echo ""
  echo "例（プロジェクトルートから）:"
  echo "  ./Common/01_dockerRunTemporary.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh"
  exit 1
fi

ENV_FILE_PATH="$1"

# ========================================
# 環境ファイルの存在確認
# ========================================

if [[ ! -f "${ENV_FILE_PATH}" ]]; then
  echo "エラー: 環境ファイルが見つかりません: ${ENV_FILE_PATH}"
  exit 1
fi

# ========================================
# パス解決
# ========================================

# 環境ファイルの絶対パスとディレクトリを取得
ENV_FILE_ABS_PATH="$(cd "$(dirname "${ENV_FILE_PATH}")" && pwd)/$(basename "${ENV_FILE_PATH}")"
ENV_DIR="$(dirname "${ENV_FILE_ABS_PATH}")"

# プロジェクトルートを計算
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# マウントソースは環境ファイルと同じディレクトリ
MOUNT_SOURCE="${ENV_DIR}"

# ========================================
# 共通ライブラリの読み込み
# ========================================

# shellcheck source=./common.sh
source "${PROJECT_ROOT}/Common/common.sh"

# 環境ファイルを読み込み
# shellcheck source=../cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh
source "${ENV_FILE_ABS_PATH}"

# ========================================
# Docker コマンドの存在確認
# ========================================

check_docker_command || error_exit "Docker が利用できません"

# ========================================
# コンテナ起動
# ========================================

log_info "一時コンテナを起動します（終了時に自動削除）"
log_info "  コンテナ名: ${ENV_CONTAINER_NAME}"
log_info "  イメージ: ${ENV_IMAGE_NAME}"
log_info "  マウント: ${MOUNT_SOURCE} -> ${ENV_MOUNT_TARGET}"

# コンテナ起動オプション
# --rm: 終了時に自動削除
# --mount: ホストディレクトリをバインドマウント
# -w: 作業ディレクトリ設定
# セキュリティオプション:
#   --user: ホストユーザーと同じUID/GIDで実行（権限最小化）
#   --read-only: ルートファイルシステムを読み取り専用化
#   --tmpfs: 書き込み可能な一時ディレクトリをメモリ上に作成
if docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /home/circleci/.m2 \
  --tmpfs /home/circleci/.gradle \
  --mount type=bind,source="${MOUNT_SOURCE}",target="${ENV_MOUNT_TARGET}" \
  -w "${ENV_MOUNT_TARGET}" \
  --name "${ENV_CONTAINER_NAME}" \
  "${ENV_IMAGE_NAME}" \
  "/bin/bash"; then
  log_success "コンテナが正常に終了しました"
else
  error_exit "コンテナの起動または実行に失敗しました"
fi
