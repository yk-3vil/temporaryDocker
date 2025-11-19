#!/usr/bin/env bash

# Docker コンテナ起動スクリプト（デタッチドコンテナ、共通化版）
# バックグラウンドで起動し、無限ループで実行し続ける
#
# 使用方法:
#   - 各imageディレクトリから: ../Common/02_dockerRunDetached.sh env_cimg_openjdk_21_0_9.sh
#   - プロジェクトルートから: ./Common/02_dockerRunDetached.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh

# ========================================
# 引数チェック
# ========================================

if [[ $# -ne 1 ]]; then
  echo "使用方法: $0 <環境ファイルパス>"
  echo ""
  echo "例（各imageディレクトリから）:"
  echo "  ../Common/02_dockerRunDetached.sh env_cimg_openjdk_21_0_9.sh"
  echo ""
  echo "例（プロジェクトルートから）:"
  echo "  ./Common/02_dockerRunDetached.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh"
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

log_info "デタッチドコンテナを起動します（バックグラウンド実行）"
log_info "  コンテナ名: ${ENV_CONTAINER_NAME}"
log_info "  イメージ: ${ENV_IMAGE_NAME}"
log_info "  マウント: ${MOUNT_SOURCE} -> ${ENV_MOUNT_TARGET}"

# コンテナ起動オプション
# -d: デタッチドモード（バックグラウンド実行）
# --mount: ホストディレクトリをバインドマウント
# -w: 作業ディレクトリ設定
# セキュリティオプション:
#   --user: ホストユーザーと同じUID/GIDで実行（権限最小化）
#   --read-only: ルートファイルシステムを読み取り専用化
#   --tmpfs: 書き込み可能な一時ディレクトリをメモリ上に作成
if CONTAINER_ID=$(docker run -d \
  --user "$(id -u):$(id -g)" \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /home/circleci/.m2 \
  --tmpfs /home/circleci/.gradle \
  --mount type=bind,source="${MOUNT_SOURCE}",target="${ENV_MOUNT_TARGET}" \
  -w "${ENV_MOUNT_TARGET}" \
  --name "${ENV_CONTAINER_NAME}" \
  "${ENV_IMAGE_NAME}" \
  "/bin/bash" -c "while :; do sleep 10; done"); then
  log_success "コンテナが起動しました"
  log_info "  コンテナID: ${CONTAINER_ID}"
  log_info "アタッチするには: docker exec -it ${ENV_CONTAINER_NAME} /bin/bash"
  log_info "停止するには: docker stop ${ENV_CONTAINER_NAME}"
else
  error_exit "コンテナの起動に失敗しました"
fi
