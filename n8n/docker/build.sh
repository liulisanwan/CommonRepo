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

# 检测并安装Docker
detect_and_install_docker() {
  # 检查Docker是否已安装
  if command -v docker >/dev/null 2>&1; then
    echo "Docker 已安装，版本: $(docker --version)"
    
    # 检查Docker服务是否运行
    if docker info >/dev/null 2>&1; then
      echo "Docker 服务正在运行"
    else
      echo "Docker 已安装但服务未运行，正在启动Docker服务..."
      # 尝试启动Docker服务
      if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo systemctl start docker
        sudo systemctl enable docker
      elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "请手动启动Docker Desktop"
        echo "或使用命令: open -a Docker"
      elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "请手动启动Docker Desktop"
      fi
      
      # 等待Docker服务启动
      echo "等待Docker服务启动..."
      for i in {1..30}; do
        if docker info >/dev/null 2>&1; then
          echo "Docker 服务启动成功"
          break
        fi
        sleep 1
        if [ $i -eq 30 ]; then
          echo "错误：Docker 服务启动超时，请手动启动Docker"
          exit 1
        fi
      done
    fi
    return 0
  fi

  echo "检测到Docker未安装，正在检测操作系统并安装..."
  
  # 检测操作系统并安装Docker
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux系统
    if command -v apt-get >/dev/null 2>&1; then
      # Debian/Ubuntu系统
      echo "检测到Ubuntu/Debian系统，安装Docker..."
      # 更新包索引
      sudo apt-get update
      # 安装必要的包
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
      # 添加Docker的官方GPG密钥
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      # 设置stable仓库
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      # 安装Docker Engine
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      # 启动Docker服务
      sudo systemctl start docker
      sudo systemctl enable docker
      # 将当前用户添加到docker组
      sudo usermod -aG docker $USER
      echo "请注意：您需要重新登录以使docker组权限生效"
    elif command -v yum >/dev/null 2>&1; then
      # CentOS/RHEL系统
      echo "检测到CentOS/RHEL系统，安装Docker..."
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo systemctl start docker
      sudo systemctl enable docker
      sudo usermod -aG docker $USER
    elif command -v dnf >/dev/null 2>&1; then
      # Fedora系统
      echo "检测到Fedora系统，安装Docker..."
      sudo dnf -y install dnf-plugins-core
      sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
      sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo systemctl start docker
      sudo systemctl enable docker
      sudo usermod -aG docker $USER
    elif command -v pacman >/dev/null 2>&1; then
      # Arch Linux系统
      echo "检测到Arch Linux系统，安装Docker..."
      sudo pacman -S --noconfirm docker docker-compose
      sudo systemctl start docker
      sudo systemctl enable docker
      sudo usermod -aG docker $USER
    else
      echo "错误：无法检测到支持的Linux包管理器，请手动安装Docker"
      echo "请访问 https://docs.docker.com/engine/install/ 查看安装说明"
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS系统
    echo "检测到macOS系统"
    if command -v brew >/dev/null 2>&1; then
      echo "使用Homebrew安装Docker Desktop..."
      brew install --cask docker
      echo "请手动启动Docker Desktop应用程序"
    else
      echo "请手动下载并安装Docker Desktop for Mac"
      echo "下载地址: https://desktop.docker.com/mac/main/amd64/Docker.dmg"
      exit 1
    fi
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows系统
    echo "检测到Windows系统"
    echo "请手动下载并安装Docker Desktop for Windows"
    echo "下载地址: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    echo "安装完成后请重启系统并启动Docker Desktop"
    exit 1
  else
    echo "错误：无法识别的操作系统类型: $OSTYPE"
    echo "请手动安装Docker"
    echo "访问 https://docs.docker.com/get-docker/ 查看安装说明"
    exit 1
  fi

  # 验证Docker安装
  echo "等待Docker安装完成并启动服务..."
  for i in {1..60}; do
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
      echo "Docker 安装并启动成功，版本: $(docker --version)"
      break
    fi
    sleep 1
    if [ $i -eq 60 ]; then
      echo "错误：Docker 安装验证超时"
      echo "请检查Docker是否正确安装并手动启动服务"
      exit 1
    fi
  done
}

# 执行系统检测和jq安装
detect_os_and_install_jq

# 执行Docker检测和安装
detect_and_install_docker

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