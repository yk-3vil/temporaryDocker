#!/usr/bin/env bash

# 共通エラーハンドリングとユーティリティ関数ライブラリ
# すべてのシェルスクリプトで読み込んで使用する基盤機能

# ========================================
# 厳格モード設定
# ========================================

# エラー時即座に終了、未定義変数使用時エラー、パイプライン全体でエラー検知
set -Eeuo pipefail

# フィールド区切り文字を改行とタブに限定（スペースを除外）
IFS=$'\n\t'

# ========================================
# エラートラップ設定
# ========================================

# エラー発生時のトラップハンドラ
# 引数: なし
# 戻り値: なし（終了コード1で終了）
_error_handler() {
  local line_number="${1:-unknown}"
  local command="${2:-unknown}"
  log_error "スクリプトがエラーで終了しました"
  log_error "  行番号: ${line_number}"
  log_error "  コマンド: ${command}"
  exit 1
}

# ERRシグナルでエラーハンドラを実行
trap '_error_handler ${LINENO} "${BASH_COMMAND}"' ERR

# ========================================
# カラーコード定義
# ========================================

# ターミナル出力用のANSIカラーコード
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# ========================================
# ログ出力関数
# ========================================

# エラーメッセージをstderrに出力
# 引数: $1 - エラーメッセージ
# 戻り値: 0（正常終了）
log_error() {
  echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# 成功メッセージをstdoutに出力
# 引数: $1 - 成功メッセージ
# 戻り値: 0（正常終了）
log_success() {
  echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

# 警告メッセージをstderrに出力
# 引数: $1 - 警告メッセージ
# 戻り値: 0（正常終了）
log_warning() {
  echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

# 情報メッセージをstdoutに出力
# 引数: $1 - 情報メッセージ
# 戻り値: 0（正常終了）
log_info() {
  echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

# ========================================
# エラー終了関数
# ========================================

# エラーメッセージを出力して終了
# 引数: $1 - エラーメッセージ
# 戻り値: なし（終了コード1で終了）
error_exit() {
  log_error "$*"
  exit 1
}

# ========================================
# Docker コマンド存在確認
# ========================================

# Docker コマンドの存在確認
# 引数: なし
# 戻り値: 0（存在する）、1（存在しない）
check_docker_command() {
  if ! command -v docker &> /dev/null; then
    log_error "Docker コマンドが見つかりません"
    log_error "Docker をインストールしてから再度実行してください"
    return 1
  fi

  log_info "Docker コマンドが利用可能です"
  return 0
}
