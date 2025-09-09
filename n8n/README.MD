# N8N中文版部署指南

本文档详细说明如何使用Docker部署N8N中文版，并配置Nginx反向代理和PostgreSQL数据库。

## 环境要求

- Docker 和 Docker Compose
- Nginx
- 域名，假设为n8n.yourdomain.com（已配置解析到服务器）

## 快速部署
### 1. 从Github下载代码
```bash
git clone https://github.com/liulisanwan/CommonRepo.git
cd CommonRepo
```
克隆完成后，你会看到以下目录结构：
```
n8n/
├── docker/         # Docker相关配置文件
│   ├── build.basic.sh
│   ├── build.sh
│   ├── docker-compose.yaml
│   ├── docker-compose.basic.yaml
│   └── env.template
└── nginx/          # Nginx配置文件
    └── n8n.conf
```
如果选择最简化安装，只需执行以下三行
```bash
cd n8n/docker
chmod +x build.basic.sh
./build.basic.sh
```
完整安装Postgre以及HTTPS支持，需要多些几个步骤

### 2. 配置环境变量
2.1 复制环境变量模板：

```bash
cd n8n/docker
cp env.template .env
nano .env
```

2.2 修改环境变量（注意：必须先配置域名相关设置）：
```env
# 首先修改以下两项，确保使用HTTPS
# 替换为你的域名
N8N_HOST=n8n.yourdomain.com
# 替换为你的域名，必须使用HTTPS
WEBHOOK_URL=https://n8n.yourdomain.com

# 其他配置项
# PostgreSQL用户名
POSTGRES_USER=root
# PostgreSQL密码
POSTGRES_PASSWORD=n8n!yyds
# PostgreSQL数据库名                     
POSTGRES_DB=n8n
# 中文界面的关键配置项    
N8N_DEFAULT_LOCALE=zh-CN

# Cloudflare Tunnel配置
CLOUDFLARE_TUNNEL_TOKEN=xxx

# 以下两项会由build.sh自动生成，无需手动设置（非生产环境可以屏蔽）
# 首次运行build.sh时自动生成，请记下来
N8N_ENCRYPTION_KEY=
# 首次运行build.sh时自动生成，请记下来                      
N8N_USER_MANAGEMENT_JWT_SECRET=
```

### 3. 构建和启动服务
3.1 设置build.sh脚本权限并执行：
```bash
chmod +x build.sh
./build.sh
```

3.2 检查服务状态，此时应该能看到n8n暴露了5678端口：
```bash
docker ps
```

### 4. 配置cloudflare
![image-20250909103706635](https://liuli-sanwan.oss-cn-beijing.aliyuncs.com/pic/image-20250909103706635.png)

![image-20250909103752400](https://liuli-sanwan.oss-cn-beijing.aliyuncs.com/pic/image-20250909103752400.png)

![image-20250909103909008](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20250909103909008.png)



### 5. 配置HTTPS


## 特性说明

1. **中文界面**：已默认配置中文界面，无需额外设置
2. **数据持久化**：
   - PostgreSQL数据存储在Docker卷中
   - 工作流和凭证会自动备份到backup目录
3. **自动导入**：系统会自动导入backup目录下的凭证和工作流

## 常见问题

1. **无法访问界面**
   - 检查Docker容器状态
   - 确认Nginx配置是否正确
   - 验证域名解析是否生效

2. **数据库连接失败**
   - 检查环境变量中的数据库配置
   - 确认PostgreSQL容器是否正常运行

3. **Webhook无法使用**
   - 确保WEBHOOK_URL配置正确
   - 检查域名SSL证书是否有效

## 安全建议

1. 建议配置SSL证书，启用HTTPS
2. 定期备份数据库和工作流
3. 使用强密码，定期更换加密密钥

## 备份凭证和工作流

```bash
sudo docker compose exec n8n n8n export:workflow --all --output=/home/node/backup/workflows
sudo docker compose exec n8n n8n export:credentials --all --output=/home/node/backup/credentials
```
