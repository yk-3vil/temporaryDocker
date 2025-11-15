#!/usr/bin/env bash

# 共通 Docker 操作関数ライブラリ
# Docker コンテナ・イメージの操作を関数化し、処理の一元化を実現

# 注意: このファイルは common.sh に依存（log_* 関数を使用）
# 使用前に common.sh を source すること

# ========================================
# コンテナ停止関数
# ========================================

# Docker コンテナを停止
# 引数: $1 - コンテナ名
# 戻り値: 0（成功、既に停止済みまたは存在しない場合も含む）、1（引数エラー）
docker_stop_container() {
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

# ========================================
# コンテナ削除関数
# ========================================

# Docker コンテナを削除（通常削除 → 強制削除のリトライ付き）
# 引数: $1 - コンテナ名
# 戻り値: 0（成功、既に削除済みまたは存在しない場合も含む）、1（引数エラー）
docker_remove_container() {
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

# ========================================
# イメージ削除関数
# ========================================

# Docker イメージを削除（通常削除 → 強制削除のリトライ付き）
# 引数: $1 - イメージ名
# 戻り値: 0（成功、既に削除済みまたは存在しない場合も含む）、1（引数エラー）
docker_remove_image() {
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

# ========================================
# コンテナ削除検証関数
# ========================================

# Docker コンテナが削除されたことを検証
# 引数: $1 - コンテナ名
# 戻り値: 0（削除済み）、1（まだ存在する）
docker_verify_container_removed() {
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

# ========================================
# イメージ削除検証関数
# ========================================

# Docker イメージが削除されたことを検証
# 引数: $1 - イメージ名
# 戻り値: 0（削除済み）、1（まだ存在する）
docker_verify_image_removed() {
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
