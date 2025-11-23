#!/usr/bin/env bash
#
################################################################################
# Script Description
# Overview:
#   共通エラーハンドリングとユーティリティ関数ライブラリ
#   すべてのシェルスクリプトで読み込んで使用する基盤機能
# Usage:
#   source "${PROJECT_ROOT}/Common/common.sh"
# Arguments:
#   なし
# Returns:
#   なし（関数定義とグローバル変数設定のみ）
# Notes:
#   厳格モード（set -Eeuo pipefail）を適用し、エラートラップを設定
#   ANSIカラーコードによるログ出力関数を提供
# Example:
#   source "${PROJECT_ROOT}/Common/common.sh"
#   check_docker_command || error_exit "Docker が利用できません"
#   log_info "処理を開始します"
################################################################################

# ==============================================================================
# 厳格モード設定
# ==============================================================================

# エラー時即座に終了、未定義変数使用時エラー、パイプライン全体でエラー検知
set -Eeuo pipefail

# フィールド区切り文字を改行とタブに限定（スペースを除外）
IFS=$'\n\t'

# ==============================================================================
# エラートラップ設定
# ==============================================================================

################################################################################
# Function Description:
#   エラー発生時のトラップハンドラ
# Overview:
#   スクリプトエラー発生時に呼び出され、エラー情報を出力して終了
# Arguments:
#   $1: 行番号（LINENO から渡される）
#   $2: 失敗したコマンド（BASH_COMMAND から渡される）
# Returns/Outputs:
#   stderrにエラー情報を出力後、終了コード1で終了
# Notes:
#   ERRシグナルでトラップされる内部関数
# Example:
#   trap '_error_handler ${LINENO} "${BASH_COMMAND}"' ERR
################################################################################
function _error_handler() {
  local line_number="${1:-unknown}"
  local command="${2:-unknown}"
  log_error "スクリプトがエラーで終了しました"
  log_error "  行番号: ${line_number}"
  log_error "  コマンド: ${command}"
  exit 1
}

# ERRシグナルでエラーハンドラを実行
trap '_error_handler ${LINENO} "${BASH_COMMAND}"' ERR

# ==============================================================================
# カラーコード定義
# ==============================================================================

# ターミナル出力用のANSIカラーコード
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

################################################################################
# Function Description:
#   エラーメッセージをstderrに出力
# Overview:
#   赤色のANSIカラーコードで [ERROR] プレフィックス付きメッセージを出力
# Arguments:
#   $*: エラーメッセージ（複数引数可）
# Returns/Outputs:
#   stderrに赤色でフォーマットされたエラーメッセージを出力、終了コード0を返却
# Notes:
#   標準エラー出力（>&2）にリダイレクト
# Example:
#   log_error "Docker コマンドが見つかりません"
################################################################################
function log_error() {
  echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

################################################################################
# Function Description:
#   成功メッセージをstdoutに出力
# Overview:
#   緑色のANSIカラーコードで [SUCCESS] プレフィックス付きメッセージを出力
# Arguments:
#   $*: 成功メッセージ（複数引数可）
# Returns/Outputs:
#   stdoutに緑色でフォーマットされた成功メッセージを出力、終了コード0を返却
# Notes:
#   標準出力に出力
# Example:
#   log_success "Docker イメージのビルドが完了しました"
################################################################################
function log_success() {
  echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

################################################################################
# Function Description:
#   警告メッセージをstderrに出力
# Overview:
#   黄色のANSIカラーコードで [WARNING] プレフィックス付きメッセージを出力
# Arguments:
#   $*: 警告メッセージ（複数引数可）
# Returns/Outputs:
#   stderrに黄色でフォーマットされた警告メッセージを出力、終了コード0を返却
# Notes:
#   標準エラー出力（>&2）にリダイレクト
# Example:
#   log_warning "コンテナの停止に失敗、またはコンテナが起動していません"
################################################################################
function log_warning() {
  echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

################################################################################
# Function Description:
#   情報メッセージをstdoutに出力
# Overview:
#   青色のANSIカラーコードで [INFO] プレフィックス付きメッセージを出力
# Arguments:
#   $*: 情報メッセージ（複数引数可）
# Returns/Outputs:
#   stdoutに青色でフォーマットされた情報メッセージを出力、終了コード0を返却
# Notes:
#   標準出力に出力
# Example:
#   log_info "Docker イメージをビルドします..."
################################################################################
function log_info() {
  echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

################################################################################
# Function Description:
#   エラーメッセージを出力して終了
# Overview:
#   log_error 関数でエラーメッセージを出力後、終了コード1でスクリプトを終了
# Arguments:
#   $*: エラーメッセージ（複数引数可）
# Returns/Outputs:
#   stderrにエラーメッセージを出力後、終了コード1でプロセスを終了
# Notes:
#   スクリプトの致命的エラー時に使用
# Example:
#   check_docker_command || error_exit "Docker が利用できません"
################################################################################
function error_exit() {
  log_error "$*"
  exit 1
}

################################################################################
# Function Description:
#   Docker コマンドの存在確認
# Overview:
#   システムに Docker コマンドがインストールされているかを確認
# Arguments:
#   なし
# Returns/Outputs:
#   Docker が利用可能な場合は終了コード0を返却
#   Docker が見つからない場合はエラーメッセージを出力し終了コード1を返却
# Notes:
#   command -v docker で存在確認を実施
# Example:
#   check_docker_command || error_exit "Docker が利用できません"
################################################################################
function check_docker_command() {
  if ! command -v docker &> /dev/null; then
    log_error "Docker コマンドが見つかりません"
    log_error "Docker をインストールしてから再度実行してください"
    return 1
  fi

  log_info "Docker コマンドが利用可能です"
  return 0
}
