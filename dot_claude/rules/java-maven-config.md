# Java / Maven 环境配置

## 适用范围
仅适用于 Java/Maven 项目。非 Java 项目请忽略本文件。

## Maven settings.xml 配置

**核心要求**: 所有对 `mvn` 命令的调用（如 `mvn test`, `mvn compile` 等），都**必须**使用 `--settings`（或 `-s`）参数来指定一个自定义的 `settings.xml` 文件，以确保能够访问内部的 Maven 仓库。

- **命令格式示例**: `mvn --settings [settings.xml的绝对路径] test`
- **`settings.xml` 文件路径**: `[settings.xml的绝对路径]`

Agent 在执行任何 Maven 命令前，必须确认此路径已被正确配置和使用。

> **TODO**: 请将 `[settings.xml的绝对路径]` 替换为实际的 settings.xml 文件路径。
