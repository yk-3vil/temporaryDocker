#!/usr/bin/env bash
#
################################################################################
# Script Description
# Overview:
#   共通 Docker 操作関数ライブラリ
#   Docker コンテナ・イメージの操作を関数化し、処理の一元化
# Usage:
#   source "${PROJECT_ROOT}/Common/common.sh"
#   source "${PROJECT_ROOT}/Common/docker_common.sh"
# Arguments:
#   なし
# Returns:
#   なし（関数定義のみ）
# Notes:
#   このファイルは common.sh に依存（log_* 関数を使用）
#   使用前に必ず common.sh を source すること
#   すべての削除系関数はべき等性を保証（既に削除済みでもエラーにならない）
# Example:
#   source "${PROJECT_ROOT}/Common/common.sh"
#   source "${PROJECT_ROOT}/Common/docker_common.sh"
#   docker_stop_container "${ENV_CONTAINER_NAME}"
#   docker_remove_container "${ENV_CONTAINER_NAME}"
################################################################################

################################################################################
# Function Description:
#   Docker コンテナを停止
# Overview:
#   指定されたコンテナを停止し、べき等性を保証
# Arguments:
#   $1: コンテナ名
# Returns/Outputs:
#   成功時は終了コード0を返却（既に停止済みまたは存在しない場合も含む）
#   引数エラー時は終了コード1を返却
# Notes:
#   べき等性を保証：既に停止済みまたは存在しない場合も成功として扱う
# Example:
#   docker_stop_container "${ENV_CONTAINER_NAME}"
################################################################################
function docker_stop_container() {
  local container_name="$1"

  # 引数チェック
  if [ -z "${container_name}" ]; then
    log_error "docker_stop_container: コンテナ名が指定されていません"
    return 1
  fi

  log_info "コンテナを停止しています: ${container_name}"
  if docker stop "${container_name}" 2>/dev/null; then
    log_success "コンテナが停止しました"
    return 0
  else
    log_warning "コンテナの停止に失敗、またはコンテナが起動していません（既に停止済みまたは存在しない可能性）"
    # 既に停止済みまたは存在しない場合も成功として扱う（べき等性を保証）
    return 0
  fi
}

################################################################################
# Function Description:
#   Docker コンテナを削除（通常削除 → 強制削除のリトライ付き）
# Overview:
#   指定されたコンテナを削除し、失敗時は強制削除を試行
#   べき等性を保証
# Arguments:
#   $1: コンテナ名
# Returns/Outputs:
#   成功時は終了コード0を返却（既に削除済みまたは存在しない場合も含む）
#   引数エラー時は終了コード1を返却
# Notes:
#   通常削除失敗時は docker rm -f で強制削除を試行
#   べき等性を保証：既に削除済みまたは存在しない場合も成功として扱う
# Example:
#   docker_remove_container "${ENV_CONTAINER_NAME}"
################################################################################
function docker_remove_container() {
  local container_name="$1"

  # 引数チェック
  if [ -z "${container_name}" ]; then
    log_error "docker_remove_container: コンテナ名が指定されていません"
    return 1
  fi

  log_info "コンテナを削除しています: ${container_name}"
  if docker rm "${container_name}" 2>/dev/null; then
    log_success "コンテナが削除されました"
    return 0
  else
    log_warning "通常削除に失敗、強制削除を試行します..."
    if docker rm -f "${container_name}" 2>/dev/null; then
      log_success "コンテナが強制削除されました"
      return 0
    else
      log_warning "コンテナの削除に失敗しました（既に削除済みまたは存在しない可能性）"
      # 既に削除済みまたは存在しない場合も成功として扱う（べき等性を保証）
      return 0
    fi
  fi
}

################################################################################
# Function Description:
#   Docker イメージを削除（通常削除 → 強制削除のリトライ付き）
# Overview:
#   指定されたイメージを削除し、失敗時は強制削除を試行
#   べき等性を保証
# Arguments:
#   $1: イメージ名
# Returns/Outputs:
#   成功時は終了コード0を返却（既に削除済みまたは存在しない場合も含む）
#   引数エラー時は終了コード1を返却
# Notes:
#   通常削除失敗時は docker rmi -f で強制削除を試行
#   べき等性を保証：既に削除済みまたは存在しない場合も成功として扱う
# Example:
#   docker_remove_image "${ENV_IMAGE_NAME}"
################################################################################
function docker_remove_image() {
  local image_name="$1"

  # 引数チェック
  if [ -z "${image_name}" ]; then
    log_error "docker_remove_image: イメージ名が指定されていません"
    return 1
  fi

  log_info "イメージを削除しています: ${image_name}"
  if docker rmi "${image_name}" 2>/dev/null; then
    log_success "イメージが削除されました"
    return 0
  else
    log_warning "通常削除に失敗、強制削除を試行します..."
    if docker rmi -f "${image_name}" 2>/dev/null; then
      log_success "イメージが強制削除されました"
      return 0
    else
      log_warning "イメージの削除に失敗しました（既に削除済み、存在しない、または使用中の可能性）"
      # 既に削除済みまたは存在しない場合も成功として扱う（べき等性を保証）
      return 0
    fi
  fi
}

################################################################################
# Function Description:
#   Docker コンテナが削除されたことを検証
# Overview:
#   指定されたコンテナが削除されたことを確認
# Arguments:
#   $1: コンテナ名
# Returns/Outputs:
#   削除済みの場合は終了コード0を返却
#   まだ存在する場合はエラーメッセージを出力し終了コード1を返却
# Notes:
#   docker ps -a で全コンテナをリストし、grep で存在確認
# Example:
#   docker_verify_container_removed "${ENV_CONTAINER_NAME}"
################################################################################
function docker_verify_container_removed() {
  local container_name="$1"

  # 引数チェック
  if [ -z "${container_name}" ]; then
    log_error "docker_verify_container_removed: コンテナ名が指定されていません"
    return 1
  fi

  if docker ps -a --filter "name=${container_name}" --format "{{.Names}}" | grep -q "^${container_name}$"; then
    log_error "コンテナがまだ存在しています"
    return 1
  else
    log_success "コンテナの削除を確認しました"
    return 0
  fi
}

################################################################################
# Function Description:
#   Docker イメージが削除されたことを検証
# Overview:
#   指定されたイメージが削除されたことを確認
# Arguments:
#   $1: イメージ名
# Returns/Outputs:
#   削除済みの場合は終了コード0を返却
#   まだ存在する場合はエラーメッセージを出力し終了コード1を返却
# Notes:
#   docker images で全イメージをリストし、grep で存在確認
# Example:
#   docker_verify_image_removed "${ENV_IMAGE_NAME}"
################################################################################
function docker_verify_image_removed() {
  local image_name="$1"

  # 引数チェック
  if [ -z "${image_name}" ]; then
    log_error "docker_verify_image_removed: イメージ名が指定されていません"
    return 1
  fi

  if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image_name}$"; then
    log_error "イメージがまだ存在しています"
    return 1
  else
    log_success "イメージの削除を確認しました"
    return 0
  fi
}
