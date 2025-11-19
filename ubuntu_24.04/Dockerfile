# ベースイメージをdigest固定で指定（再現性とセキュリティ向上）
FROM docker.io/ubuntu:24.04@sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5

# ビルド引数の定義
ARG CREATED_DATE

# OCI推奨LABELの設定
LABEL org.opencontainers.image.title="Ubuntu 24.04 Development Environment"
LABEL org.opencontainers.image.description="Ubuntu 24.04 LTS with essential development tools"
LABEL org.opencontainers.image.version="24.04"
LABEL org.opencontainers.image.created="${CREATED_DATE}"

# APTの非対話モード設定
ARG DEBIAN_FRONTEND=noninteractive

# ホストのUID/GIDをビルド引数として受け取る（デフォルト値: 1000）
ARG BUILD_UID=1000
ARG BUILD_GID=1000

# 追加パッケージのインストール（堅牢化のためset -euxを使用）
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    vim \
    git \
    curl \
    wget \
    sudo \
    ca-certificates; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# 開発ユーザー(devuser)の作成
# ホストのUID/GIDと一致させることで、ファイル権限の問題を回避
# 既存ユーザー(ubuntu)は保持し、UID衝突時は既存ユーザーのUIDを移動
RUN set -eux; \
  DEVUSER=devuser; \
  DEVGROUP="${DEVUSER}"; \
  if getent group "${BUILD_GID}" > /dev/null 2>&1; then \
    DEVGROUP="$(getent group "${BUILD_GID}" | cut -d: -f1)"; \
    echo "Reusing existing group ${DEVGROUP} (GID: ${BUILD_GID})"; \
  else \
    groupadd --gid "${BUILD_GID}" "${DEVGROUP}"; \
    echo "Created new group ${DEVGROUP} (GID: ${BUILD_GID})"; \
  fi; \
  if getent passwd "${BUILD_UID}" > /dev/null 2>&1; then \
    EXISTING_USER="$(getent passwd "${BUILD_UID}" | cut -d: -f1)"; \
    if [ "${EXISTING_USER}" != "${DEVUSER}" ]; then \
      echo "UID ${BUILD_UID} is used by ${EXISTING_USER}, moving to different UID"; \
      SAFE_UID=$((BUILD_UID + 1)); \
      while getent passwd "${SAFE_UID}" > /dev/null 2>&1; do \
        SAFE_UID=$((SAFE_UID + 1)); \
      done; \
      echo "Moving ${EXISTING_USER} from UID ${BUILD_UID} to ${SAFE_UID}"; \
      usermod --uid "${SAFE_UID}" "${EXISTING_USER}"; \
      find / -xdev \( -path /proc -o -path /sys -o -path /dev \) -prune -o \
        -uid "${BUILD_UID}" -exec chown -h "${SAFE_UID}" {} + 2>/dev/null || true; \
    fi; \
  fi; \
  if ! id -u "${DEVUSER}" > /dev/null 2>&1; then \
    useradd --uid "${BUILD_UID}" --gid "${BUILD_GID}" \
            --home-dir /home/"${DEVUSER}" --create-home \
            --shell /bin/bash "${DEVUSER}"; \
    echo "Created user ${DEVUSER} (UID: ${BUILD_UID}, GID: ${BUILD_GID})"; \
  fi; \
  usermod -a -G "${DEVGROUP}" "${DEVUSER}"; \
  echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 作業ディレクトリの作成と権限設定
RUN set -eux; \
  mkdir -p /workspace; \
  chown -R "${BUILD_UID}":"${BUILD_GID}" /workspace

# 開発ユーザーに切り替え
USER devuser

# 作業ディレクトリの設定
WORKDIR /workspace

# デフォルトコマンド
CMD ["/bin/bash"]
