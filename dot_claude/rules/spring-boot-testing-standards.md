---
paths:
  - "**/src/test/**/*.java"
  - "**/*{Test,IT}.java"
---

# Spring Boot 测试规范

> 基于 [通用测试规范](./testing-standards.md)，为 Spring Boot 2.x+ / 3.x+ 项目提供细粒度测试指导。
> 测试框架：JUnit 5 + Mockito + AssertJ。

---

## 1. 最小测试上下文原则

**核心原则：优先使用最小测试上下文，不要滥用 `@SpringBootTest`。**

| 场景 | 推荐方案 | 加载范围 |
|------|---------|---------|
| Service 单元测试 | Mockito + JUnit | 不启动 Spring 容器 |
| Controller 测试 | `@WebMvcTest` | 仅 Web 层 |
| Repository 测试 | `@DataJpaTest` / `@MyBatisTest` | 仅数据访问层 |
| JSON 序列化测试 | `@JsonTest` | 仅 Jackson 组件 |
| 完整链路测试 | `@SpringBootTest` | 完整容器 |

---

## 2. Service 测试

- 优先使用**纯单元测试**，不启动 Spring 容器
- 标准写法：`@ExtendWith(MockitoExtension.class)` + `@Mock` + `@InjectMocks`
- Arrange-Act-Assert 三段式

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void findById_existingUser_returnsUser() {
        User user = new User(1L, "张三");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        User result = userService.findById(1L);

        assertThat(result.getName()).isEqualTo("张三");
    }
}
```

❌ **禁止**用 `@SpringBootTest` 测 Service。

---

## 3. Controller 测试

- 使用 `@WebMvcTest(XxxController.class)` 只加载 Web 层
- 用 `@MockBean` 模拟 Service 层

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @MockBean
    private UserService userService;

    @Autowired
    private MockMvc mockMvc;

    @Test
    void getUser_existingId_returns200() throws Exception {
        when(userService.findById(1L)).thenReturn(new User(1L, "张三"));
        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("张三"));
    }
}
```

---

## 4. Repository 测试

- **必须使用真实数据库环境**，不允许 Mock Repository / Mapper
- `@DataJpaTest` / `@MyBatisTest` 默认含 `@Transactional`，自动回滚

```java
@DataJpaTest
class UserRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    @Test
    void findByEmail_existingEmail_returnsUser() {
        entityManager.persistAndFlush(new User("张三", "zhang@test.com"));
        Optional<User> result = userRepository.findByEmail("zhang@test.com");
        assertThat(result).isPresent();
        assertThat(result.get().getName()).isEqualTo("张三");
    }
}
```

**禁止**使用 H2 替代生产数据库验证复杂 SQL（方言差异）。优先使用 Testcontainers。

---

## 5. JSON 测试

使用 `@JsonTest` + `JacksonTester` 验证序列化与反序列化。

---

## 6. 完整链路测试

- 使用 `@SpringBootTest` 验证完整 Spring 容器行为
- 验证事务、配置、组件之间的协作
- **不要将 `@SpringBootTest` 作为默认测试方式**

---

## 7. Testcontainers 规范

### 7.1 基本原则

- 集成测试优先使用 Testcontainers
- 保证测试环境与生产环境一致
- 避免依赖开发机器本地数据库

### 7.2 基本用法

```java
@Testcontainers
@DataJpaTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:tc:postgresql:17:///testdb",
    "spring.datasource.driver-class-name=org.testcontainers.jdbc.ContainerDatabaseDriver"
})
class UserRepositoryIT {
    @Autowired
    private UserRepository userRepository;
}
```

### 7.3 单例容器模式

多个测试类共享同一个容器实例以避免启停开销。定义抽象基类 + `@DynamicPropertySource`，测试类继承基类即可共享。详见 [Testcontainers 官方文档](https://java.testcontainers.org/)。

❌ **禁止**：

```java
spring.datasource.url=jdbc:mysql://localhost:3306/test  // 依赖开发机本地数据库
```

---

## 8. 禁止项

- ❌ 所有测试都用 `@SpringBootTest`
- ❌ 单元测试启动 Spring 容器
- ❌ Repository 测试 Mock 数据库
- ❌ 集成测试 Mock 核心业务组件

---

## 9. 相关文档

- **通用测试规范**：[testing-standards.md](./testing-standards.md)
- **Property-Based Testing 规范**：[property-based-testing.md](./property-based-testing.md) —— Java 用 jqwik；强制档场景（序列化 / 解析 / 算法 / 状态机）必须写 PBT
- **TDD 开发流程**：[tdd-development-flow.md](./tdd-development-flow.md)
