##N8N工作流和凭证导入/导出
首先文档如下：https://docs.n8n.io/hosting/cli-commands/#export-workflows-and-credentials

N8N_ENCRYPTION_KEY必须一致，才能保证导出后能被正常导入(除非使用--backup以明文形式导出)

### 导出所有工作流和凭证到文件workflows和credentials
```
sudo docker compose exec n8n n8n export:workflow --all --output=/home/node/backup/workflows
sudo docker compose exec n8n n8n export:credentials --all --output=/home/node/backup/credentials
```
这种导入方式，恢复时会只能覆盖的方式进行
```
n8n import:credentials --input=/home/node/backup/credentials && n8n import:workflow --input=/home/node/backup/workflows
```


### 导出所有工作流和凭证到文件夹workflows_folder和credentials_folder
```
sudo docker compose exec n8n n8n export:workflow --all --separate --output=/home/node/backup/workflows_folder
sudo docker compose exec n8n n8n export:credentials --all --separate --output=/home/node/backup/credentials_folder
```
这种方式恢复的时候，会以增量方式导入
```
n8n import:credentials --separate --input=/home/node/backup/credentials_folder && n8n import:workflow --separate --input=/home/node/backup/workflows_folder
```

### 明文方式导出工作流和凭证到文件夹workflows_folder和credentials_folder
```
sudo docker compose exec n8n n8n export:workflow --backup --output=/home/node/backup/workflows_folder
sudo docker compose exec n8n n8n export:credentials --backup --output=/home/node/backup/credentials_folder
```
这种方式恢复时，会以增量方式导入，可以用于secret key不一样的实例之间迁移(--decrypted参数似乎已经不再支持)
```
n8n import:credentials --separate --input=/home/node/backup/credentials_folder && n8n import:workflow --separate --input=/home/node/backup/workflows_folder
```