# PRD: .NET 5 → .NET 8 云原生迁移

> **工作坊用途：** [模块 2 — 遗留代码库现代化](../../legacy-modernization.md) 的练习。演示了 agy 严格模式、使用 AGENTS.md 进行代理自我引导、子代理计划，以及使用 `ctrl+g` 编辑计划。目标仓库包含一个由 GCP 云解决方案架构师编写的参考文件 `modernization-prompt.md`——这是用于迁移任务的提示词工程的黄金标准示例。
>

## 问题

一个部分升级的 ASP.NET 应用程序 (ContosoUniversity) 运行在 .NET 5 上，使用 Entity Framework 6 和传统的泛型主机模式 (`Startup.cs` + `Program.cs`)。.NET 5 已于 2022 年 5 月结束支持。该应用程序使用 SQL Server 风格的 EF6，但需要以使用 PostgreSQL 的 Cloud Run 为目标。它缺乏容器化、结构化日志记录和优雅停机处理。

## 业务驱动力

| 驱动力 | 影响 |
| :-- | :-- |
| **安全合规** | .NET 5 已达到生命周期终点 (EOL) — 无安全补丁。阻碍合规认证。 |
| **部署速度** | 从手动虚拟机部署转变为在 Cloud Run 上 3 分钟完成容器推送 |
| **可扩展性** | Cloud Run 根据流量自动从 0 扩展到 N 个实例 |
| **成本** | 消除 Windows Server 许可费用 — Cloud Run 上的 Linux 容器成本降低约 70% |
| **数据层** | 从 EF6/SQL Server 迁移到 EF Core 8/PostgreSQL，以使用托管的 Cloud SQL |

## 目标仓库

[ContosoUniversity — Google Cloud .NET 现代化演示](https://github.com/GoogleCloudPlatform/cloud-solutions/tree/main/projects/dotnet-modernization-demo)

该仓库提供了遗留应用（`dotnet-migration-sample/`）和已完成的目标状态（`dotnet-migration-sample-modernized/`）以供自我验证。学员将专门在 `dotnet-migration-sample/` 目录中进行操作。

```bash
git clone --depth 1 https://github.com/GoogleCloudPlatform/cloud-solutions.git
cd cloud-solutions/projects/dotnet-modernization-demo/dotnet-migration-sample
```

> **额外资源：** 该仓库包含 [`modernization-prompt.md`](https://github.com/GoogleCloudPlatform/cloud-solutions/blob/main/projects/dotnet-modernization-demo/modernization-prompt.md) ——这是一个来自 GCP 团队的 225 行生产级迁移提示词。将你的代理的方法与此参考进行比较，以学习用于迁移任务的提示词工程。
>

## 范围

### 包含范围

- 将目标框架从 .NET 5 升级到 .NET 8
- 将通用主机模式（`Startup.cs`）替换为最小托管 API（`WebApplication.CreateBuilder()`）
- 将 Entity Framework 6 迁移到 Entity Framework Core 8
- 将数据库提供程序从 SQL Server 切换为 PostgreSQL (Npgsql)
- 创建兼容 Cloud Run 的 Dockerfile 和 Docker Compose 配置
- 实现结构化日志记录、PORT 绑定和 SIGTERM 优雅关闭

### 不包含范围

- 业务逻辑更改（忠实进行 1:1 功能复制）
- 前端重新设计（Razor 视图保持原样，只需确保它们能够编译）
- 数据库架构更改（EF Core 应映射到等效的架构）

## 迁移清单

### 阶段 0：上下文工程 — 代理自我入职

在编写迁移代码之前，代理应该建立自己对代码库的理解。

- [ ] **设置严格模式** — 防止在调查期间意外写入文件：

  ```text
  /permissions strict
  ```

- [ ] **调查代码库：**

  ```text
  分析 ContosoUniversity 应用程序。映射：
  1. 当前框架版本和所有 NuGet 依赖项
  2. Startup.cs/Program.cs 托管模式
  3. 跨 DAL、控制器和迁移的所有 System.Data.Entity (EF6) 使用情况
  4. 配置源（appsettings.json、web.config 残留）
  5. Google Cloud 集成（Diagnostics、日志记录）
  ```

- [ ] 基于分析结果**生成感知迁移的 AGENTS.md**
- [ ] 在继续之前**审查并批准**生成的 AGENTS.md
- [ ] 在阶段 1 之前**切换到请求审查模式**：

  ```text
  /permissions request-review
  ```

### 阶段 1：TFM 和包升级

- [ ] 更新 `ContosoUniversity.csproj`：将 `<TargetFramework>net5.0</TargetFramework>` 更改为 `net8.0`
- [ ] 将所有 NuGet 包更新为兼容 .NET 8 的版本：
  - `Microsoft.AspNetCore.Mvc.NewtonsoftJson` → 8.0.x
  - `System.ComponentModel.Annotations` → 8.0.x
  - `System.Configuration.ConfigurationManager` → 8.0.x
  - `Google.Cloud.Diagnostics.AspNetCore` → 最新的 8.0 兼容版本
- [ ] 移除 `Microsoft.DotNet.UpgradeAssistant.Extensions.Default.Analyzers` 包（不再需要）
- [ ] 移除 `<GenerateAssemblyInfo>false</GenerateAssemblyInfo>` 并删除 `Properties/AssemblyInfo.cs`
- [ ] 运行 `dotnet restore` — 解决任何包冲突

### 阶段 2：托管现代化

- [ ] 使用最小托管 API 替换 `Startup.cs` + `Program.cs`（通用主机模式）：

  ```csharp
  var builder = WebApplication.CreateBuilder(args);
  builder.Services.AddControllersWithViews();
  // ... 服务注册
  var app = builder.Build();
  // ... 中间件管道
  app.Run();
  ```

- [ ] 将 `ConfigureServices()` 主体移动到顶层 `builder.Services` 块中
- [ ] 将 `Configure()` 主体移动到顶层 `app.Use*()` 管道中
- [ ] 将 `CreateHostBuilder` 机密配置加载迁移到新模式
- [ ] 为 Cloud Run 配置 PORT 绑定：`app.Run("http://0.0.0.0:" + port)`
- [ ] 添加 SIGTERM 优雅关闭处理程序
- [ ] 迁移完成后删除 `Startup.cs`

### 阶段 3：Entity Framework 6 → EF Core 8

- [ ] 移除 `EntityFramework` 6.4.4 包
- [ ] 添加 `Microsoft.EntityFrameworkCore` 和 `Npgsql.EntityFrameworkCore.PostgreSQL` 8.0.x
- [ ] 重构 `SchoolContext`：
  - 将 `System.Data.Entity` 导入替换为 `Microsoft.EntityFrameworkCore`
  - 在 `OnModelCreating` 中将 `DbModelBuilder` 替换为 `ModelBuilder`
  - 移除 `PluralizingTableNameConvention` → 添加显式的 `.ToTable()` 调用
  - 移除 `MapToStoredProcedures()`（EF Core 中不支持）
  - 替换构造函数 `SchoolContext(string connectString) : base(connectString)` → `SchoolContext(DbContextOptions<SchoolContext> options) : base(options)`
- [ ] 在 DI 中注册 DbContext：`builder.Services.AddDbContext<SchoolContext>(options => options.UseNpgsql(...))`
- [ ] 使用 `context.Database.EnsureCreated()` 将 `SchoolInitializer.cs` 重构为 `DbInitializer.cs`
- [ ] 移除 `SchoolConfiguration.cs`（`Database.SetInitializer<T>()` 仅限 EF6）
- [ ] 移除 `SchoolInterceptorLogging.cs` 和 `SchoolInterceptorTransientErrors.cs`（EF6 拦截器）→ 替换为通过 `ILoggerFactory` 实现的 EF Core 日志记录
- [ ] 删除所有 EF6 迁移文件（`Migrations/2014*.cs`，`Migrations/Configuration.cs`）
- [ ] 更新所有控制器以移除 `System.Data.Entity` 导入，并将 `RetryLimitExceededException`（EF6）修复为 EF Core 等效项
- [ ] 运行 `dotnet build` — 修复所有编译错误

### 阶段 4：容器化与 Cloud Run

- [ ] 创建多阶段 `Dockerfile`：

  ```dockerfile
  FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
  WORKDIR /src
  COPY . .
  RUN dotnet publish -c Release -o /app

  FROM mcr.microsoft.com/dotnet/aspnet:8.0
  WORKDIR /app
  COPY --from=build /app .
  USER 1000
  EXPOSE 8080
  ENTRYPOINT ["dotnet", "ContosoUniversity.dll"]
  ```

- [ ] 添加 `.dockerignore`（排除 `bin/`、`obj/`、`.git/`）
- [ ] 创建包含 PostgreSQL + 应用服务的 `compose.yaml`：
  - 带有 `pg_isready` 健康检查的 PostgreSQL 容器
  - 通过环境变量提供连接字符串的应用容器
  - 没有 `version` 属性（在 Compose 规范中已弃用）
- [ ] 为 Cloud Logging 配置结构化 JSON 日志记录：`builder.Logging.AddJsonConsole()`
- [ ] 运行 `docker build --check .` — 通过所有 Docker 构建检查
- [ ] 运行 `docker compose up --build --detach` — 验证应用程序是否启动以及数据库是否初始化

### 阶段 5：验证与测试

- [ ] `dotnet build` 编译无错误或警告
- [ ] Docker 镜像在 Linux 上构建并运行（非 Windows 容器）
- [ ] 容器以非 root 用户身份运行（UID 1000）
- [ ] 所有 HTTP 端点均正确响应（用于 CRUD 操作的 GET、POST）
- [ ] 首次运行时使用种子数据初始化数据库
- [ ] 应用程序正确处理 POST/DELETE 操作的防伪令牌
- [ ] 结构化 JSON 日志出现在 `docker compose logs` 中
- [ ] 源代码中没有连接字符串或凭据

## 代理应该做什么

本 PRD 旨在测试代理的以下能力：

1. **引导其自身上下文** — 在开始之前，使用严格模式 + 代码库调查来编写 AGENTS.md（阶段 0）
2. **理解遗留模式** — 识别 EF6 惯用法（`DbModelBuilder`、拦截器、`Database.SetInitializer`）并将它们映射到 EF Core 的等效项
3. **遵循分阶段的计划** — 在执行之前使用 `ctrl+g` 编辑并批准计划
4. **执行机械式重构** — EF6 → EF Core 的迁移会涉及每个控制器和模型文件
5. **验证其自身工作** — 在每个阶段之后运行 `dotnet build` 和 `docker compose up`
6. **使用 `/rewind`** 如果某个阶段出错 — 这是你的检查点，而不是失败

## 验收标准

- [ ] 项目根目录下存在一个 `AGENTS.md` 文件，用于编码迁移上下文
- [ ] `dotnet build` 在 .NET 8 上编译无错误
- [ ] 代码库中不再保留任何 `System.Data.Entity` 导入
- [ ] 没有 `Startup.cs` — 应用程序在 `Program.cs` 中使用最小托管 API
- [ ] `EntityFramework` 6.x 包已完全替换为 `Microsoft.EntityFrameworkCore` 8.x
- [ ] Docker 镜像在 Linux 上使用非 root 用户构建并运行
- [ ] `docker compose up` 成功启动应用程序和 PostgreSQL，并填充数据库
- [ ] 源代码中没有连接字符串或凭据
- [ ] 应用程序在冷启动后 2 秒内响应健康检查
