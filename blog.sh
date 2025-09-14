#!/usr/bin/env bash
set -euo pipefail

# Simple local helper for Hugo + Stack
# Usage:
#   ./blog.sh           # = serve
#   ./blog.sh serve     # run local dev server
#   ./blog.sh build     # build to ./public
#   ./blog.sh new slug  # create new leaf bundle post at content/posts/slug/index.md
#   ./blog.sh clean     # clean build artifacts and module cache

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

msg() { printf "\033[1;34m[blog]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[blog]\033[0m %s\n" "$*" 1>&2; }

need_hugo() {
  if command -v hugo >/dev/null 2>&1; then
    return 0
  fi
  err "Hugo が見つかりません。以下のいずれかを実施してください:"
  err "- macOS: brew install hugo"
  err "- Debian/Ubuntu: sudo apt-get install hugo (extended)"
  err "- Windows: choco install hugo-extended または winget install Hugo.Hugo.Extended"
  err "- 公式: https://github.com/gohugoio/hugo/releases" 
  exit 1
}

ensure_theme() {
  # Clone Stack theme into themes/ if missing
  if [ -d "themes/hugo-theme-stack" ]; then
    return 0
  fi
  msg "Stack テーマを取得します…"
  mkdir -p themes
  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 https://github.com/CaiJimmy/hugo-theme-stack.git themes/hugo-theme-stack
  else
    err "git が必要です。インストール後に再実行してください。"
    exit 1
  fi
}

serve() {
  need_hugo
  ensure_theme
  msg "ローカルサーバーを起動します (http://localhost:1313)"
  exec hugo server -D --disableFastRender --bind 0.0.0.0 --baseURL "http://localhost:1313/"
}

build() {
  need_hugo
  ensure_theme
  msg "本番ビルドを作成します (./public)"
  hugo --gc --minify
  msg "完了: public/ を確認してください"
}

clean() {
  msg "生成物を削除します…"
  rm -rf public resources _vendor .hugo_build.lock || true
  rm -rf themes/hugo-theme-stack || true
  msg "クリーン完了"
}

new_post() {
  need_hugo
  slug="${1:-}"
  if [ -z "$slug" ]; then
    err "Usage: $0 new <folder-name>"
    exit 2
  fi
  target_dir="content/posts/$slug"
  target_file="$target_dir/index.md"
  if [ -e "$target_file" ]; then
    err "既に存在します: $target_file"
    exit 1
  fi
  msg "新規記事を作成します: posts/$slug"
  # テーマ取得は不要だが、初回環境で不足が出ないよう一応実施
  ensure_theme
  if hugo new "posts/$slug/index.md" >/dev/null; then
    if [ -f "$target_file" ]; then
      msg "作成しました: $target_file"
      msg "フロントマターを編集し、準備ができたら draft: false にしてください。"
    else
      err "作成に失敗しました (ファイルが見つかりません): $target_file"
      exit 1
    fi
  else
    err "hugo new の実行に失敗しました"
    exit 1
  fi
}

cmd="${1:-serve}"
case "$cmd" in
  serve|dev) serve ;;
  build) build ;;
  clean) clean ;;
  new) new_post "${2:-}" ;;
  *) err "Unknown command: $cmd"; err "Usage: $0 [serve|build|clean|new]"; exit 2 ;;
esac
