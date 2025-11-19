# ベースイメージをdigest固定で指定（再現性とセキュリティ向上）
FROM docker.io/cimg/openjdk:21.0.9@sha256:488f1b4f69e50aed578889c302ae9812479ae43924fa02eafc55055f779ea8dd

# OCI推奨LABELの設定
LABEL org.opencontainers.image.title="OpenJDK 21.0.9 Development Environment"
LABEL org.opencontainers.image.description="CircleCI OpenJDK 21.0.9 image with vim for development"
LABEL org.opencontainers.image.version="21.0.9"
LABEL org.opencontainers.image.created="2025-11-13T00:00:00Z"

# APTの非対話モード設定
ARG DEBIAN_FRONTEND=noninteractive

# ホストのUID/GIDをビルド引数として受け取る（デフォルト値: 1000）
ARG USER_ID=1000
ARG GROUP_ID=1000

# root権限への切り替え（パッケージインストールとユーザー設定のため）
USER root

# 追加パッケージのインストール（堅牢化のためset -euxを使用）
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    vim; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# circleci ユーザーのUID/GIDをホストと一致させる
# これにより、コンテナ内でホストのUID/GIDでユーザー名が正しく表示される
RUN set -eux; \
  groupmod -g "${GROUP_ID}" circleci; \
  usermod -u "${USER_ID}" -g "${GROUP_ID}" circleci; \
  chown -R "${USER_ID}":"${GROUP_ID}" /home/circleci

# 元のユーザー(circleci)に戻す
USER circleci

# デフォルトコマンド
CMD ["/bin/bash"]