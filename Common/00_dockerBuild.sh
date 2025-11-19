#!/usr/bin/env bash

# Docker イメージビルドスクリプト（共通化版）
# 任意の環境ファイルを引数として受け取り、イメージをビルド
#
# 使用方法:
#   - 各imageディレクトリから: ../Common/00_dockerBuild.sh env_cimg_openjdk_21_0_9.sh
#   - プロジェクトルートから: ./Common/00_dockerBuild.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh

# ========================================
# 引数チェック
# ========================================

if [[ $# -ne 1 ]]; then
  echo "使用方法: $0 <環境ファイルパス>"
  echo ""
  echo "例（各imageディレクトリから）:"
  echo "  ../Common/00_dockerBuild.sh env_cimg_openjdk_21_0_9.sh"
  echo ""
  echo "例（プロジェクトルートから）:"
  echo "  ./Common/00_dockerBuild.sh cimg_openjdk_21.0.9/env_cimg_openjdk_21_0_9.sh"
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

# Dockerfile のパスは環境ファイルと同じディレクトリ
DOCKERFILE_PATH="${ENV_DIR}/Dockerfile"

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
# イメージビルド
# ========================================

log_info "Docker イメージをビルドします..."
log_info "  イメージ名: ${ENV_IMAGE_NAME}"
log_info "  Dockerfile: ${DOCKERFILE_PATH}"
log_info "  ビルドコンテキスト: ${ENV_DIR}"
log_info "  ホストUID: $(id -u)"
log_info "  ホストGID: $(id -g)"

# イメージビルド実行
# ホストのUID/GIDをビルド引数として渡し、コンテナ内のユーザーと一致させる
if docker build \
  --build-arg USER_ID="$(id -u)" \
  --build-arg GROUP_ID="$(id -g)" \
  -f "${DOCKERFILE_PATH}" \
  -t "${ENV_IMAGE_NAME}" \
  "${ENV_DIR}"; then
  log_success "Docker イメージのビルドが完了しました"
else
  error_exit "Docker イメージのビルドに失敗しました"
fi
