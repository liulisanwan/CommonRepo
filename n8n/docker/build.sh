#!/bin/bash

# 检测操作系统并安装jq
detect_os_and_install_jq() {
  # 检查jq是否已安装
  if command -v jq >/dev/null 2>&1; then
    echo "jq 已安装，版本: $(jq --version)"
    return 0
  fi

  echo "检测到jq未安装，正在检测操作系统并安装..."
  
  # 检测操作系统
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux系统
    if command -v apt-get >/dev/null 2>&1; then
      # Debian/Ubuntu系统
      echo "检测到Ubuntu/Debian系统，使用apt-get安装jq..."
      sudo apt-get update
      sudo apt-get install -y jq
    elif command -v yum >/dev/null 2>&1; then
      # CentOS/RHEL系统
      echo "检测到CentOS/RHEL系统，使用yum安装jq..."
      sudo yum install -y jq
    elif command -v dnf >/dev/null 2>&1; then
      # Fedora系统
      echo "检测到Fedora系统，使用dnf安装jq..."
      sudo dnf install -y jq
    elif command -v pacman >/dev/null 2>&1; then
      # Arch Linux系统
      echo "检测到Arch Linux系统，使用pacman安装jq..."
      sudo pacman -S --noconfirm jq
    else
      echo "错误：无法检测到支持的Linux包管理器，请手动安装jq"
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS系统
    if command -v brew >/dev/null 2>&1; then
      echo "检测到macOS系统，使用Homebrew安装jq..."
      brew install jq
    else
      echo "错误：macOS系统需要安装Homebrew才能自动安装jq"
      echo "请访问 https://brew.sh/ 安装Homebrew，或手动安装jq"
      exit 1
    fi
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows系统（Git Bash或Cygwin环境）
    echo "检测到Windows系统（MSYS/Cygwin环境）"
    if command -v pacman >/dev/null 2>&1; then
      # MSYS2环境
      echo "使用MSYS2 pacman安装jq..."
      pacman -S --noconfirm jq
    else
      echo "警告：无法在当前Windows环境下自动安装jq"
      echo "请手动安装jq或使用MSYS2/WSL环境"
      echo "您可以从 https://github.com/stedolan/jq/releases 下载jq.exe"
      exit 1
    fi
  else
    echo "错误：无法识别的操作系统类型: $OSTYPE"
    echo "请手动安装jq"
    exit 1
  fi

  # 验证安装
  if command -v jq >/dev/null 2>&1; then
    echo "jq 安装成功，版本: $(jq --version)"
  else
    echo "错误：jq 安装失败"
    exit 1
  fi
}

# 执行系统检测和jq安装
detect_os_and_install_jq

# 加载 .env 文件
set -a
source .env
set +a

# 检查 .env 文件是否存在
if [ ! -f ".env" ]; then
  echo "错误：.env 文件不存在。请创建并配置 .env 文件。"
  exit 1
fi

# 检查 ENCRYPTION_KEY 和 N8N_USER_MANAGEMENT_JWT_SECRET 是否已设置
if [ -z "$N8N_ENCRYPTION_KEY" ]; then
  echo "ENCRYPTION_KEY 未设置，正在生成随机值..."
  ENCRYPTION_KEY=$(openssl rand -hex 16)
  echo "ENCRYPTION_KEY=$ENCRYPTION_KEY"
  # 使用 sed 命令更新 .env 文件
  sed -i "s/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY/" .env
  echo "ENCRYPTION_KEY 已自动添加到 .env 文件。"
fi

if [ -z "$N8N_USER_MANAGEMENT_JWT_SECRET" ]; then
  echo "N8N_USER_MANAGEMENT_JWT_SECRET 未设置，正在生成随机值..."
  JWT_SECRET=$(openssl rand -hex 16)
  echo "N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET"
  # 使用 sed 命令更新 .env 文件
  sed -i "s/^N8N_USER_MANAGEMENT_JWT_SECRET=.*/N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET/" .env
  echo "N8N_USER_MANAGEMENT_JWT_SECRET 已自动添加到 .env 文件。"
fi

# -----  自动下载并解压 editor-ui.tar.gz  -----

# 设置 dist 目录
DIST_DIR="./dist"

# 确保 dist 目录存在
mkdir -p "$DIST_DIR"

# 如果 backup 目录不存在则创建
mkdir -p backup
# 确保Docker容器中具有正确的权限
chown -R 1000:1000 ./backup 
chmod -R 775 ./backup

# 获取下载 URL
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/other-blowsnow/n8n-i18n-chinese/releases/latest | jq -r '.assets[] | select(.name == "editor-ui.tar.gz") | .browser_download_url')

# 检查是否成功获取 URL
if [ -z "$DOWNLOAD_URL" ]; then
  echo "错误：无法获取 editor-ui.tar.gz 的下载 URL。请检查网络连接和 GitHub API 是否可用。"
  exit 1
fi

echo "下载 URL: $DOWNLOAD_URL"

# 下载文件
echo "正在下载 editor-ui.tar.gz..."

# 使用代理下载
wget -O editor-ui.tar.gz https://gh-proxy.com/"$DOWNLOAD_URL"

# 检查下载是否成功
if [ ! -f "editor-ui.tar.gz" ]; then
  echo "错误：下载 editor-ui.tar.gz 失败。请检查 URL 和网络连接。"
  exit 1
fi

echo "editor-ui.tar.gz 下载完成。"

# 解压文件到 dist 目录
echo "正在解压 editor-ui.tar.gz 到 $DIST_DIR..."
tar -xzf editor-ui.tar.gz -C "$DIST_DIR" --strip-components 1

# 检查解压是否成功 (简单检查，可以根据需要完善)
# 检查 dist 目录下是否存在关键文件 (例如 index.html)
if [ ! -f "$DIST_DIR/index.html" ]; then
  echo "错误：解压 editor-ui.tar.gz 失败。请检查文件是否损坏或解压路径是否正确。"
  exit 1
fi

echo "editor-ui.tar.gz 解压完成。"

# 清理下载的压缩包
rm -f editor-ui.tar.gz

echo "已清理下载的压缩包 editor-ui.tar.gz"

# -----  自动下载并解压完成  -----

# 启动 Docker Compose
docker compose up -d