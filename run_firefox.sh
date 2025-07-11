#!/bin/sh

set -e  # 遇到错误就退出

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 更新系统并安装 curl
echo "检查并安装 curl..."
if ! command -v curl >/dev/null 2>&1; then
  if command -v apt >/dev/null 2>&1; then
    apt update && apt upgrade -y && apt install -y curl
  elif command -v yum >/dev/null 2>&1; then
    yum update -y && yum install -y curl
  elif command -v dnf >/dev/null 2>&1; then
    dnf upgrade -y && dnf install -y curl
  else
    echo "${RED}不支持的包管理器，无法安装 curl${NC}"
    exit 1
  fi
else
  echo "curl 已安装"
fi

# 2. 检查并安装 Docker 和 Docker Compose
echo "检查 Docker..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

echo "检查 Docker Compose..."
if ! command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_VERSION="2.24.6"
  curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# 3. 创建目录并进入
mkdir -p /opt/web_firefox && cd /opt/web_firefox

# 4. 下载 compose 文件（请替换成你实际的直链地址）
COMPOSE_URL="https://cdn.jsdelivr.net/gh/suyuli458/doc-games@refs/heads/firefox/docker-to-firefox.yaml"
curl -fsSL "$COMPOSE_URL" -o docker-compose.yaml

# 5. 启动项目并检查状态
echo "启动服务..."
if docker compose up -d; then
  echo "${GREEN}ok${NC}"
else
  echo "${RED}启动失败，请检查日志${NC}"
  exit 1
fi
