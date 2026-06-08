# PRD：Java 8 → Java 21 与 Spring Boot 3 迁移

> **工作坊用途：** [模块 2 — 遗留代码库现代化](../../legacy-modernization.md)的练习。演示大上下文代码库调查模式、AGENTS.md 自主上手，以及 agy 如何处理对人类来说容易出错的机械式命名空间迁移。
>

## 问题

一个企业级 Java REST API (Spring PetClinic REST) 运行在 Java 8 和 Spring Boot 2.6.x 上。Java 8 已于 2022 年停止公开更新。该应用程序无法使用虚拟线程、现代 GC 改进或最新的安全补丁。合规性要求迁移到一个受支持的 LTS 版本。

## 业务驱动力

| 驱动力 | 影响 |
| :-- | :-- |
| **安全合规** | Java 8 已 EOL —— 无安全补丁。审计发现的问题阻碍了下一次 SOC 2 续签。 |
| **性能** | Java 21 虚拟线程减少了高并发端点上的线程池争用。预计 p99 延迟降低 30%。 |
| **成本** | 内存占用的改善意味着可以使用更小的容器实例。预计节省 20% 的基础设施成本。 |
| **开发者体验** | 记录类、密封类、模式匹配、文本块 —— 减少约 15% 的样板代码。 |

## 范围

### 包含范围

- 从 Java 8 升级到 Java 21 (LTS)
- 从 Spring Boot 2.6.x 升级到 Spring Boot 3.3.x
- 从 javax.*迁移到 jakarta.* 命名空间
- 替换已弃用的安全配置 (`WebSecurityConfigurerAdapter`)
- 将 OpenAPI/Swagger 从 SpringFox 迁移到 SpringDoc
- 启用虚拟线程
- 确保所有现有测试通过

### 不包含范围

- 微服务拆分（单体架构保持不变）
- 数据库模式更改
- 新功能开发

## 工作坊环境设置：版本对齐

为了确保迁移练习与本 PRD 中定义的目标状态保持一致，请使用 **tag `v2.6.2`** 版本的 **Spring PetClinic REST** 变体。这个特定的标签作为我们稳定的基线——它使用 **Spring Boot 2.6.2 和 Java 8**，并且关键是包含了使用 `WebSecurityConfigurerAdapter` 的真实 Spring Security 配置，使得安全迁移阶段更加真实。

```bash
git clone --branch v2.6.2 --depth 1 https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
```

> **为什么选择这个变体？** 主 `spring-petclinic` 仓库从未包含过 Spring Security。该 REST 变体具有继承自 `WebSecurityConfigurerAdapter` 的 `BasicAuthenticationConfig`，包含基于 JDBC 的身份验证、`@PreAuthorize` 基于角色的访问控制以及 CORS 配置——所有这些模式都需要手动迁移到 Spring Security 6。
>

## 迁移清单

### 阶段 0：上下文工程 — 代理自我引导

在编写任何一行迁移代码之前，代理应该建立自己对代码库的理解。此阶段使用**自我引导**模式：代理读取整个项目，映射架构模式，并生成一个 `AGENTS.md` 来编码它所学到的内容 —— 实际上是在编写它自己的上下文文件。

- [ ] **设置严格模式** — 在调查期间不进行写入：

  ```text
  /permissions strict
  ```

- [ ] **调查代码库：**

  ```text
  分析整个项目结构、依赖项和架构模式。
  映射所有 Spring Security 配置类、数据访问层（JDBC、JPA、
  Spring Data）和 REST 控制器模式。
  ```

- [ ] **生成针对迁移的 AGENTS.md：**

  ```text
  根据你的分析，为该项目编写一个 AGENTS.md，要求：
  1. 记录当前架构（Boot 2.6、Java 8、javax 命名空间）
  2. 定义目标架构（Boot 3.3、Java 21、jakarta 命名空间）
  3. 列出迁移规则（一次一个模块，保留 API 契约等）
  4. 编码测试标准（每个迁移的端点必须通过测试）
  5. 记录你识别出的已知迁移风险
  ```

- [ ] 在继续之前，**审查并批准生成的 AGENTS.md**
- [ ] 在阶段 1 之前，**切换到 request-review**：

  ```text
  /permissions request-review
  ```

> **为什么这很重要：** 这是“用于迁移的上下文工程”模式。代理利用其代码库调查能力来引导生成丰富的上下文文件，而不是由人类从头开始编写 AGENTS.md。然后，代理使用此文件来指导其自身的迁移工作 —— 这是一个自我强化的循环，更好的上下文会产生更好的代码更改。

### 阶段 1：构建系统

- [ ] 更新 `pom.xml`：将 `java.version` 设置为 21
- [ ] 将 Spring Boot parent 更新为 3.3.x
- [ ] 替换已移除的 JDK API：
  - JAXB → `jakarta.xml.bind:jakarta.xml.bind-api` + Glassfish 运行时
  - `javax.annotation` → `jakarta.annotation:jakarta.annotation-api`
  - `mysql-connector-java` → `com.mysql:mysql-connector-j`
- [ ] 运行 `mvn clean compile` — 在继续之前修复所有编译错误

### 阶段 2：命名空间迁移

- [ ] 全局查找并替换：`javax.persistence` → `jakarta.persistence`
- [ ] 全局查找并替换：`javax.validation` → `jakarta.validation`
- [ ] 全局查找并替换：`javax.servlet` → `jakarta.servlet`
- [ ] 全局查找并替换：`javax.annotation` → `jakarta.annotation`
- [ ] 验证：没有剩余的 `javax.*` 导入（`javax.sql.*` 除外，它保持不变）

### 阶段 3：安全配置

- [ ] 移除继承自 `WebSecurityConfigurerAdapter` 的类（在 Spring Security 6 中已删除）：
  - `BasicAuthenticationConfig`
  - `DisableSecurityConfig`
- [ ] 创建带有 `@Bean SecurityFilterChain` 的替代 `SecurityConfig` 类
- [ ] 迁移 `.authorizeRequests()` → `.authorizeHttpRequests()`
- [ ] 迁移 `@EnableGlobalMethodSecurity` → `@EnableMethodSecurity`
- [ ] 迁移 `configureGlobal(AuthenticationManagerBuilder)` → `@Bean AuthenticationManager`
- [ ] 验证：基于 JDBC 的身份验证、基于角色的访问控制和 CORS 仍然有效

### 阶段 4：OpenAPI/Swagger 迁移

- [ ] 移除 SpringFox 依赖项（`springfox-boot-starter`、`springfox-swagger2`）
- [ ] 添加 SpringDoc 依赖项（`springdoc-openapi-starter-webmvc-ui`）
- [ ] 迁移 Swagger 注解：`@Api` → `@Tag`，`@ApiOperation` → `@Operation`
- [ ] 将 `@ApiResponse` 从 `io.swagger` 迁移到 `io.swagger.v3.oas`
- [ ] 将 `ApplicationSwaggerConfig` 更新为 SpringDoc 配置
- [ ] 验证：可以在 `/swagger-ui.html` 访问 Swagger UI

### 阶段 5：虚拟线程与验证

- [ ] 在 `application.properties` 中添加：`spring.threads.virtual.enabled=true`
- [ ] 审查所有 `@Async` 方法 — 虚拟线程使得对于 I/O 密集型工作不再需要自定义线程池
- [ ] 运行完整的测试套件：`mvn clean verify`
- [ ] 验证启动日志中没有 Spring Boot 弃用警告

## 代理应该做什么

此 PRD 旨在测试代理的以下能力：

1. **引导其自身的上下文** — 在开始迁移工作之前，通过代码库调查编写一个 AGENTS.md（阶段 0）
2. **理解完整的代码库** — 巨大的上下文窗口让 agy 可以同时看到所有文件
3. **遵循分阶段计划** — 在执行每个阶段之前，使用 `ctrl+g` 来审查计划
4. **执行机械式重构** — 命名空间迁移对人类来说是重复且容易出错的
5. **验证自身的工作** — 在每个阶段之后运行 `mvn clean verify` 并修复任何损坏
6. **使用 `/rewind`** 如果某个阶段出错 — 在安全配置重写之后特别有用

## 验收标准

- [ ] 项目根目录下存在一个 `AGENTS.md` 文件，用于编码迁移上下文
- [ ] 在 Java 21 上运行 `mvn clean verify` 通过，且测试失败数为 0
- [ ] 不保留任何 `javax.*` 导入（`javax.sql.*` 除外）
- [ ] 代码库中没有任何地方使用 `WebSecurityConfigurerAdapter`
- [ ] SpringFox 依赖项已完全被 SpringDoc 替换
- [ ] `application.properties` 包含 `spring.threads.virtual.enabled=true`
- [ ] 启动日志中没有 Spring Boot 弃用警告

## 目标仓库

[Spring PetClinic REST](https://github.com/spring-petclinic/spring-petclinic-rest) 位于标签 [`v2.6.2`](https://github.com/spring-petclinic/spring-petclinic-rest/tree/v2.6.2) — Spring Boot 2.6.2、Java 8，包含 Spring Security 和 OpenAPI。
