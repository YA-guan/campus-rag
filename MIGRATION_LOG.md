# campus-rag 项目搬迁操作记录

> 记录日期：2026-10-11
> 执行人：workbuddy（Java 后端开发助手）
> 关联远程仓库：https://github.com/YA-guan/campus-rag.git

## 一、任务背景

本周核心任务是搭建 **campus-rag（校园问答系统）** 的底座环境。由于操作失误，今天的 Git 初始化、数据库设计（`db.sql`）、Postman 验证等成果，全部做在了辅助测试项目 `servlet-mock-demo`（用于验证 Tomcat 环境）上。

本次操作的目标是：将今天的所有成果完整搬迁并落地到真正的 Spring Boot 核心项目 `demo`（由 Spring Initializr 生成）。

### 涉及路径

| 角色 | 路径 | 说明 |
| --- | --- | --- |
| 错误的辅助测试项目 | `D:\webHonde\servlet-mock-demo` | Tomcat 环境验证项目 |
| 正确的核心项目 | `D:\demo\demo` | Spring Boot 核心项目（Spring Boot 4.1.1 / Java 17） |
| 远程仓库 | `https://github.com/YA-guan/campus-rag.git` | 目标远端 |

---

## 二、执行前的现状核查（重要）

在动手前对两个项目做了完整核查，**发现实际状态与原始指令清单存在多处偏差**，特此如实记录并说明处理方式：

| 序号 | 原清单描述 | 实际核查结果 | 处理方式 |
| --- | --- | --- | --- |
| 1 | `servlet-mock-demo` 下存在 `.git`，需要删除 | **不存在 `.git` 目录**，Git 关联早已断开 | 无需删除；`db.sql` 已确认完好保留 |
| 2 | 需在 `demo` 中执行 `git init` | **已存在 `.git`**，分支为 `main`，无提交、无 remote | 跳过重复初始化（`git init` 本身幂等） |
| 3 | 远程仓库为空，直接推送即可 | **远程 `main` 已有 5 笔提交**，内容是 servlet 项目的文件（`index.jsp`、`db.sql`、`postman/`、`pom.xml`） | 采用**强制覆盖**策略，丢弃错误的 servlet 历史 |
| 4 | 清单仅提到"保留 `db.sql`" | 未说明是否搬迁 `db.sql` / `postman/` 到 demo | 经用户确认，**一并搬迁** `db.sql` + `postman/` + 更新 `.gitignore` |

### 远程仓库原有历史（搬迁前）

```
fe492a3 清理不需要版本控制的文件
8126225 设计校园问答系统数据库结构
a9956dd 重新添加文件并让 .gitignore 生效
e77f60d 更新.gitignore文件
50b7ff7 fix:解决合并冲突
```

> 说明：这 5 笔提交是基于 `servlet-mock-demo` 产生的，与 `demo` 项目无历史关联。为避免后续推送冲突、保持仓库整洁，经用户确认后采用强制覆盖方案。

---

## 三、操作步骤详录

### 第一步：备份关键文件

在执行任何操作前，先将 `servlet-mock-demo` 中的关键成果备份到独立目录：

```bash
# 备份目录（按时间戳命名）
D:\webHonde\_backup_servlet-mock-demo_20261011-214329\
```

备份内容：
- `db.sql`（数据库设计脚本）
- `postman/`（Postman 接口验证集合）
- `README.md`
- `.gitignore`

**结果**：备份成功，原文件保持不动。

---

### 第二步：清理错误项目的 Git 状态

```bash
cd D:\webHonde\servlet-mock-demo
# 检查并删除 .git
```

**执行结果**：
```
未发现 .git 目录 —— 该项目的 Git 关联早已不存在，无需删除。
db.sql 完好保留 ✓
```

**说明**：核查确认该目录下无 `.git`，Git 与远程 `campus-rag` 的关联实际已解除，本步骤无需实际操作。`db.sql` 保留在原位置。

---

### 第三步：搬迁成果文件到 demo 项目

```bash
# 1) 迁移数据库设计脚本
cp D:\webHonde\servlet-mock-demo\db.sql  D:\demo\demo\db.sql

# 2) 迁移 Postman 接口验证集合
cp -r D:\webHonde\servlet-mock-demo\postman  D:\demo\demo\postman
```

**结果**：`db.sql` 与 `postman/` 已落地到 `D:\demo\demo`。

#### `.gitignore` 更新

原 `demo` 项目的 `.gitignore` 是 Spring Initializr 生成的默认版本。按要求**合并**（而非覆盖）新增四条规则，保留原有全部内容：

```gitignore
target/
.idea/
.smarttomcat/
*.iml

HELP.md
.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
...（原有内容保留）
```

> **设计决策**：采用「合并」而非「替换」，是为了同时满足两方面的需要 —— 既包含用户要求的新规则，又不破坏 Spring 项目原本需要的忽略项（如 STS、NetBeans、VS Code 相关配置）。

---

### 第四步：在 demo 项目中初始化并配置 Git

```bash
cd D:\demo\demo

# 1) git init（因已初始化，此处为幂等操作）
git init
# 输出：Reinitialized existing Git repository in D:/demo/demo/.git/

# 2) 确保主分支名为 main
git branch -M main

# 3) 关联远程仓库
git remote add origin https://github.com/YA-guan/campus-rag.git

# 4) 暂存全部文件（.gitignore 自动生效）
git add -A
```

**暂存区核查结果**（确认忽略规则生效）：

```
A  .gitattributes
A  .gitignore
A  .mvn/wrapper/maven-wrapper.properties
A  db.sql
A  mvnw
A  mvnw.cmd
A  pom.xml
A  postman/servlet-mock-demo.postman_collection.json
A  src/main/java/com/example/demo/DemoApplication.java
A  src/main/java/com/example/demo/HelloController.java
A  src/main/resources/application.properties
A  src/test/java/com/example/demo/DemoApplicationTests.java
```

> `target/`、`.idea/`、`*.iml` **均未出现在暂存区**，证明 `.gitignore` 规则正确生效。

#### 创建首次提交

```bash
git commit -m "chore: 初始化 campus-rag 校园问答系统骨架

- 迁移 Spring Boot 项目底座（Spring Boot 4.1.1 / Java 17）
- 迁移 db.sql：users/documents/knowledge_chunks/chat_logs 四表结构
- 迁移 postman 接口验证集合
- 配置 .gitignore（target/、.idea/、.smarttomcat/、*.iml）
- 保留 HelloController 冒烟接口"
```

**结果**：
```
[main (root-commit) d0940ac] chore: 初始化 campus-rag 校园问答系统骨架
 12 files changed, 685 insertions(+)
```

---

### 第五步：强制推送覆盖远程仓库

```bash
git push -f origin main
```

**结果**：
```
To https://github.com/YA-guan/campus-rag.git
 + fe492a3...d0940ac main -> main (forced update)
```

远程 `main` 分支已由旧的 `fe492a3`（servlet 历史）被**强制覆盖**为新的干净提交 `d0940ac`。

#### 远程验证

重新克隆远程仓库进行独立验证：

```
===== 远程最终文件树 =====
.gitattributes / .gitignore / .mvn/ / db.sql / mvnw / mvnw.cmd
pom.xml / postman/ / src/main/java/com/example/demo/{DemoApplication,HelloController}.java
src/main/resources/application.properties
src/test/java/com/example/demo/DemoApplicationTests.java

===== 远程提交历史 =====
d0940ac chore: 初始化 campus-rag 校园问答系统骨架
```

**验证通过**：远程仓库为干净的单一提交，文件结构完全正确，`target/`、`.idea/` 未进入仓库。

---

## 四、编译与启动验证

### 编译检查

```bash
mvn -DskipTests compile
```

**结果**：
```
[INFO] --- compiler:3.15.0:compile (default-compile) @ demo ---
[INFO] BUILD SUCCESS
[INFO] Total time:  1.101 s
```

### 启动冒烟测试

```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar --server.port=8080
```

启动日志：
```
Tomcat initialized with port 8080 (http)
Tomcat started on port 8080 (http) with context path '/'
Started DemoApplication in 2.503 seconds
```

接口验证：
```
GET http://127.0.0.1:8080/hello
→ Hello,world!
→ HTTP_CODE: 200
```

**验证通过**：项目可正常编译、启动，`HelloController` 冒烟接口返回正确。

---

## 五、搬迁成果清单

### 已落地到 `D:\demo\demo` 的文件

| 文件 | 来源 | 说明 |
| --- | --- | --- |
| `db.sql` | servlet-mock-demo | 校园问答系统数据库设计（4 张表） |
| `postman/servlet-mock-demo.postman_collection.json` | servlet-mock-demo | Postman 接口验证集合 |
| `.gitignore` | 新建 + 合并 | 新增 4 条忽略规则，保留原有 Spring 规则 |
| 原有 Spring 骨架 | demo 自带 | `pom.xml`、`src/`、`mvnw` 等 |

### `db.sql` 数据库结构概览

| 表名 | 说明 | 关键字段 |
| --- | --- | --- |
| `users` | 用户表 | `user_number`(PK), `user_name`(UNIQUE), `birthday`, `sex`, `visit_count` |
| `documents` | 文档表 | `doc_id`(PK), `title`, `source_path`, `category`, `uploader_id`(FK→users) |
| `knowledge_chunks` | 知识分块表 | `chunks_id`(PK), `content`, `embedding`, `chunks_sequence`, `doc_id`(FK→documents) |
| `chat_logs` | 对话日志表 | `log_id`(PK), `create_at`, `retrieved_chunk_ids`(BIGINT[]), `user_id`(FK→users) |

外键约束：`documents.uploader_id → users.user_number`（ON DELETE SET NULL）、`knowledge_chunks.doc_id → documents.doc_id`（ON DELETE CASCADE）、`chat_logs.user_id → users.user_number`（ON DELETE CASCADE）。

索引：`idx_chunks_doc_id`、`idx_logs_user_id`。

---

## 六、遗留事项与后续建议

### 遗留事项

1. **`servlet-mock-demo` 的后续处理**
   该项目仍保留在 `D:\webHonde\servlet-mock-demo`，其 `db.sql`、`postman/` 已复制到 demo。若确认不再需要，可自行归档或删除（**注意**：`D:\webHonde` 下还有 Maven 安装目录，切勿误删）。
   建议保留 `README.md` 中提到的 `campus-rag` 相关说明，清理时注意甄别。

2. **备份目录**
   `D:\webHonde\_backup_servlet-mock-demo_20261011-214329` 为本次操作的安全备份，确认无需回滚后可删除。

3. **Postman 集合命名**
   集合文件名为 `servlet-mock-demo.postman_collection.json`，内部 `baseUrl` 仍指向 `http://localhost:8080/servlet-mock-demo`。后续对接 campus-rag 实际接口时，建议重命名文件并更新 `baseUrl`。

4. **`db.sql` 尚未在 PostgreSQL 中执行**
   当前仅为脚本落地，尚未验证能否在 PostgreSQL 中成功建表。建议下一步用 `psql` 执行一次，确认语法无误。

### 后续建议

1. **数据库连接配置**：`application.properties` 目前仅有一行 `spring.application.name=demo`。下一步接入 PostgreSQL 时，需补充数据源配置（建议使用环境变量管理密码，不要硬编码）。

2. **技术栈规划**：campus-rag 作为问答检索系统，后续大概率需要引入向量检索能力。`knowledge_chunks` 表的 `embedding` 字段目前为 `TEXT` 类型，若数据量增长，建议评估 `pgvector` 扩展。

3. **分支保护**：本次使用了强制推送。建议在 GitHub 仓库设置中为 `main` 分支开启保护规则，避免后续误操作覆盖。

4. **IDEA 打开项目**：在 IDEA 中打开 `D:\demo\demo` 后，确认 Maven 项目已正确导入（右侧 Maven 面板可见 `demo` 模块）。

---

## 七、本次操作使用的关键命令速查

```bash
# 备份
cp -r D:\webHonde\servlet-mock-demo\db.sql   D:\webHonde\_backup_xxx\

# 搬迁
cp D:\webHonde\servlet-mock-demo\db.sql      D:\demo\demo\db.sql
cp -r D:\webHonde\servlet-mock-demo\postman  D:\demo\demo\postman

# Git 配置
cd D:\demo\demo
git init
git branch -M main
git remote add origin https://github.com/YA-guan/campus-rag.git
git add -A
git commit -m "chore: 初始化 campus-rag 校园问答系统骨架"

# 强制覆盖推送
git push -f origin main

# 编译与验证
mvn -DskipTests compile
java -jar target/demo-0.0.1-SNAPSHOT.jar --server.port=8080
curl http://127.0.0.1:8080/hello
```

---

*文档生成时间：2026-10-11 21:52*
*记录人：workbuddy*
