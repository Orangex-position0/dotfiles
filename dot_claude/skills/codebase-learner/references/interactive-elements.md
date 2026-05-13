# Interactive Elements Reference

面向后端开发者的交互元素实现模式。保留了最有价值的 8 种核心元素，新增 2 种开发者导向的元素。

> **Architecture note:** 所有 CSS 和 JavaScript 在 `references/styles.css` 和 `references/main.js` 中。写模块 HTML 时只用下面的 HTML 模式——不要内联 `<style>` 或 `<script>`。`main.js` 通过扫描类名和 `data-*` 属性自动初始化。

## Table of Contents
1. [Code ↔ Design Intent](#code--design-intent)
2. [Multiple-Choice Quizzes](#multiple-choice-quizzes)
3. [Message Flow / Data Flow Animation](#message-flow--data-flow-animation)
4. [Interactive Architecture Diagram](#interactive-architecture-diagram)
5. [Callout Boxes](#callout-boxes)
6. [Pattern/Feature Cards](#patternfeature-cards)
7. [Visual File Tree](#visual-file-tree)
8. [Numbered Step Cards](#numbered-step-cards)
9. [Call Chain Tracer](#call-chain-tracer)
10. [Comparison View](#comparison-view)
11. [Glossary Annotations](#glossary-annotations)
12. [Flow Diagrams](#flow-diagrams)
13. [Permission/Config Badges](#permissionconfig-badges)

---

## Code ↔ Design Intent

最重要的教学元素。左侧展示真实代码，右侧解释设计意图——为什么这样写、解决了什么问题、有什么替代方案。

**HTML:**
```html
<div class="translation-block animate-in">
  <div class="translation-code">
    <span class="translation-label">CODE</span>
    <pre><code>
<span class="code-line"><span class="code-keyword">const</span> cache = <span class="code-keyword">new</span> <span class="code-function">LRUCache</span>({</span>
<span class="code-line">  <span class="code-property">max</span>: <span class="code-number">100</span>,</span>
<span class="code-line">  <span class="code-property">ttl</span>: <span class="code-number">60000</span></span>
<span class="code-line">});</span>
    </code></pre>
  </div>
  <div class="translation-english">
    <span class="translation-label">DESIGN INTENT</span>
    <div class="translation-lines">
      <p class="tl">LRU 缓存策略——淘汰最近最少使用的条目，限制 100 条，60 秒过期。</p>
      <p class="tl">这是空间换时间的优化：API 调用密集场景下减少重复请求。</p>
      <p class="tl">替代方案：多实例部署时考虑 Redis 做分布式缓存。</p>
    </div>
  </div>
</div>
```

**Rules:**
- 代码必须是原始代码的精确复制
- 右侧解释聚焦于：设计意图、解决的问题、权衡取舍、替代方案
- 不解释语法（读者是开发者）
- 选择 5-15 行能体现设计模式或关键决策的代码片段

---

## Multiple-Choice Quizzes

测试架构判断力和设计决策理解。

**Wiring:** `main.js` 暴露 `window.selectOption(btn)`, `window.checkQuiz(containerId)`, `window.resetQuiz(containerId)`。

**HTML:**
```html
<div class="quiz-container" id="quiz-module3">
  <div class="quiz-question-block"
       data-correct="option-b"
       data-explanation-right="正确——因为 X 层负责 Y，改动影响范围最小。"
       data-explanation-wrong="想想哪一层负责这个职责——改动应该封装在职责最匹配的层。">
    <h3 class="quiz-question">如果要给项目添加 Redis 缓存，应该改哪一层？为什么？</h3>
    <div class="quiz-options">
      <button class="quiz-option" data-value="option-a" onclick="selectOption(this)">
        <div class="quiz-option-radio"></div>
        <span>Controller 层——在请求入口处做缓存</span>
      </button>
      <button class="quiz-option" data-value="option-b" onclick="selectOption(this)">
        <div class="quiz-option-radio"></div>
        <span>Repository 层——数据访问的缓存是数据层的职责</span>
      </button>
      <button class="quiz-option" data-value="option-c" onclick="selectOption(this)">
        <div class="quiz-option-radio"></div>
        <span>Service 层——业务逻辑决定何时用缓存</span>
      </button>
    </div>
    <div class="quiz-feedback"></div>
  </div>

  <button class="quiz-check-btn" onclick="checkQuiz('quiz-module3')">Check Answers</button>
  <button class="quiz-reset-btn" onclick="resetQuiz('quiz-module3')">Try Again</button>
</div>
```

**Question types (by value):**
1. Design decision — "Why did the project choose X over Y?"
2. Architecture judgment — "To add feature Z, which modules change?"
3. Code tracing — "A request goes through these layers: ..."
4. Trade-off analysis — "If we switch from X to Y, what breaks?"

---

## Message Flow / Data Flow Animation

逐步可视化请求在组件/层之间的流转。

**Wiring:** `main.js` 自动初始化每个 `.flow-animation`。步骤通过 `data-steps` JSON 传入。

> **Warning:** `data-steps` 属性用单引号定界，标签中不能出现单引号（`'`），否则 JSON 解析会静默失败。用 `&apos;` 替代。

**HTML:**
```html
<div class="flow-animation" data-steps='[
  {"highlight":"flow-actor-1","label":"HTTP request hits Controller"},
  {"highlight":"flow-actor-1","label":"Controller validates input, calls Service","packet":true,"from":"actor-1","to":"actor-2"},
  {"highlight":"flow-actor-2","label":"Service applies business rules","packet":true,"from":"actor-2","to":"actor-3"},
  {"highlight":"flow-actor-3","label":"Repository builds query, executes against DB","packet":true,"from":"actor-3","to":"actor-4"}
]'>
  <div class="flow-actors">
    <div class="flow-actor" id="flow-actor-1">
      <div class="flow-actor-icon">C</div>
      <span>Controller</span>
    </div>
    <div class="flow-actor" id="flow-actor-2">
      <div class="flow-actor-icon">S</div>
      <span>Service</span>
    </div>
    <div class="flow-actor" id="flow-actor-3">
      <div class="flow-actor-icon">R</div>
      <span>Repository</span>
    </div>
    <div class="flow-actor" id="flow-actor-4">
      <div class="flow-actor-icon">D</div>
      <span>Database</span>
    </div>
  </div>

  <div class="flow-packet" id="flow-packet"></div>
  <div class="flow-step-label" id="flow-label">Click "Next Step" to begin</div>

  <div class="flow-controls">
    <button class="btn flow-next-btn">Next Step</button>
    <button class="btn flow-reset-btn">Restart</button>
    <span class="flow-progress"></span>
  </div>
</div>
```

---

## Interactive Architecture Diagram

全系统架构图，点击组件查看详细说明。

**HTML:**
```html
<div class="arch-diagram">
  <div class="arch-zone arch-zone-browser">
    <h4 class="arch-zone-label">Application Layer</h4>
    <div class="arch-component" data-desc="Receives HTTP requests, validates input, delegates to service layer. Stateless."
         onclick="showArchDesc(this)">
      <div class="arch-icon">C</div>
      <span>Controller</span>
    </div>
  </div>
  <div class="arch-zone arch-zone-external">
    <h4 class="arch-zone-label">Domain Layer</h4>
    <!-- more components -->
  </div>
  <div class="arch-description" id="arch-desc">Click any component to learn what it does</div>
</div>
```

---

## Callout Boxes

关键洞察和设计要点。每个学习单元最多 2 个。

```html
<div class="callout callout-accent">
  <div class="callout-icon">&#x1f4a1;</div>
  <div class="callout-content">
    <strong class="callout-title">Design Insight</strong>
    <p>This project uses the Repository pattern to abstract data access. This means swapping MySQL for MongoDB only requires changing the Repository implementation — the Service layer is untouched. This is the Open/Closed Principle in action.</p>
  </div>
</div>
```

**Variants:**
- `callout-accent`: accent left border — for design insights
- `callout-info`: teal left border — for "good to know" facts
- `callout-warning`: red left border — for common pitfalls or anti-patterns

---

## Pattern/Feature Cards

展示项目中使用的设计模式和工程实践。

```html
<div class="pattern-cards">
  <div class="pattern-card" style="border-top: 3px solid var(--color-actor-1)">
    <div class="pattern-icon" style="background: var(--color-actor-1)">&#x1f504;</div>
    <h4 class="pattern-title">Repository Pattern</h4>
    <p class="pattern-desc">Abstracts data access behind interfaces. The domain layer never knows if data comes from MySQL, MongoDB, or an in-memory store.</p>
  </div>
  <!-- more cards -->
</div>
```

---

## Visual File Tree

替代大段文字描述"这个目录做什么，那个目录做什么"。

```html
<div class="file-tree">
  <div class="ft-folder open">
    <span class="ft-name">src/main/java/com/example/</span>
    <span class="ft-desc">Application root package</span>
    <div class="ft-children">
      <div class="ft-folder">
        <span class="ft-name">controller/</span>
        <span class="ft-desc">HTTP entry points — receives requests, delegates to services</span>
      </div>
      <div class="ft-folder">
        <span class="ft-name">service/</span>
        <span class="ft-desc">Business logic — orchestrates domain objects and repositories</span>
      </div>
      <div class="ft-folder">
        <span class="ft-name">repository/</span>
        <span class="ft-desc">Data access interfaces — implemented in infrastructure</span>
      </div>
    </div>
  </div>
</div>
```

---

## Numbered Step Cards

展示请求处理流程、构建步骤等序列。

```html
<div class="step-cards">
  <div class="step-card">
    <div class="step-num">1</div>
    <div class="step-body">
      <strong>Request hits Controller</strong>
      <p>Spring MVC dispatches the HTTP request to the matching handler method</p>
    </div>
  </div>
  <div class="step-card">
    <div class="step-num">2</div>
    <div class="step-body">
      <strong>Controller calls Service</strong>
      <p>Input validation passes, business logic is delegated to the service layer</p>
    </div>
  </div>
</div>
```

---

## Call Chain Tracer

新增元素：可视化展示一个请求从入口到终点的调用链。

**HTML:**
```html
<div class="call-chain animate-in">
  <div class="chain-header">
    <span class="chain-label">CALL CHAIN</span>
    <span class="chain-endpoint">POST /api/users</span>
  </div>
  <div class="chain-nodes">
    <div class="chain-node" data-file="src/controller/UserController.java" data-line="45">
      <div class="chain-node-icon" style="background: var(--color-actor-1)">C</div>
      <div class="chain-node-info">
        <strong>UserController.createUser()</strong>
        <p>Validates input DTO, delegates to service</p>
        <code class="chain-file">UserController.java:45</code>
      </div>
    </div>
    <div class="chain-arrow"></div>
    <div class="chain-node" data-file="src/service/UserService.java" data-line="78">
      <div class="chain-node-icon" style="background: var(--color-actor-2)">S</div>
      <div class="chain-node-info">
        <strong>UserService.register()</strong>
        <p>Checks duplicate, hashes password, saves via repository</p>
        <code class="chain-file">UserService.java:78</code>
      </div>
    </div>
    <div class="chain-arrow"></div>
    <div class="chain-node" data-file="src/repository/UserRepository.java" data-line="22">
      <div class="chain-node-icon" style="background: var(--color-actor-4)">R</div>
      <div class="chain-node-info">
        <strong>UserRepository.save()</strong>
        <p>INSERT into users table via MyBatis mapper</p>
        <code class="chain-file">UserRepository.java:22</code>
      </div>
    </div>
  </div>
</div>
```

**CSS (add to styles.css or include inline):**
```css
.call-chain {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
  box-shadow: var(--shadow-md);
  margin: var(--space-8) 0;
}
.chain-header {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-bottom: var(--space-6);
}
.chain-label {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--color-text-muted);
}
.chain-endpoint {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--color-accent);
  background: var(--color-accent-light);
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-sm);
}
.chain-nodes {
  display: flex;
  flex-direction: column;
  gap: 0;
}
.chain-node {
  display: flex;
  align-items: flex-start;
  gap: var(--space-4);
  padding: var(--space-4);
  border-left: 2px solid var(--color-border);
  margin-left: var(--space-5);
  transition: background var(--duration-fast);
}
.chain-node:hover {
  background: var(--color-surface-warm);
}
.chain-node-icon {
  width: 32px; height: 32px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-display);
  font-size: var(--text-sm);
  font-weight: 700;
  color: white;
  flex-shrink: 0;
}
.chain-node-info strong {
  display: block;
  font-family: var(--font-mono);
  font-size: var(--text-sm);
}
.chain-node-info p {
  margin: var(--space-1) 0 0;
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
}
.chain-file {
  font-size: var(--text-xs) !important;
  color: var(--color-text-muted) !important;
}
.chain-arrow {
  width: 2px;
  height: var(--space-4);
  background: var(--color-border);
  margin-left: calc(var(--space-5) + 15px);
}
```

---

## Comparison View

新增元素：并排对比两种设计方案。

**HTML:**
```html
<div class="comparison animate-in">
  <div class="comparison-header">
    <span class="comparison-label">APPROACH COMPARISON</span>
  </div>
  <div class="comparison-columns">
    <div class="comparison-col comparison-col-left">
      <div class="comparison-col-header">
        <strong>Repository Pattern</strong>
        <span class="comparison-tag comparison-tag-current">Current</span>
      </div>
      <ul class="comparison-points">
        <li>Service layer depends on interfaces, not implementations</li>
        <li>Easy to swap database (just new Repository impl)</li>
        <li>More files and indirection</li>
      </ul>
    </div>
    <div class="comparison-col comparison-col-right">
      <div class="comparison-col-header">
        <strong>Active Record Pattern</strong>
        <span class="comparison-tag comparison-tag-alt">Alternative</span>
      </div>
      <ul class="comparison-points">
        <li>Model objects handle their own persistence</li>
        <li>Simpler for small projects, fewer files</li>
        <li>Harder to test (persistence coupled to domain)</li>
      </ul>
    </div>
  </div>
  <div class="comparison-verdict">
    <p>This project chose Repository because it needs to support multiple data sources (MySQL + Redis cache). Active Record would couple the domain to a single persistence mechanism.</p>
  </div>
</div>
```

**CSS:**
```css
.comparison {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
  box-shadow: var(--shadow-md);
  margin: var(--space-8) 0;
}
.comparison-header {
  margin-bottom: var(--space-4);
}
.comparison-label {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--color-text-muted);
}
.comparison-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}
.comparison-col {
  padding: var(--space-5);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
}
.comparison-col-header {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}
.comparison-tag {
  font-size: var(--text-xs);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
  font-weight: 600;
}
.comparison-tag-current {
  background: var(--color-success-light);
  color: var(--color-success);
}
.comparison-tag-alt {
  background: var(--color-info-light);
  color: var(--color-info);
}
.comparison-points {
  list-style: none;
  padding: 0;
}
.comparison-points li {
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
  padding: var(--space-1) 0;
  padding-left: var(--space-4);
  position: relative;
}
.comparison-points li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--color-border);
  transform: translateY(-50%);
}
.comparison-verdict {
  margin-top: var(--space-4);
  padding: var(--space-4);
  background: var(--color-accent-light);
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  color: var(--color-text-secondary);
}
.comparison-verdict p { margin: 0; }

@media (max-width: 768px) {
  .comparison-columns { grid-template-columns: 1fr; }
}
```

---

## Glossary Annotations

只在项目特有的概念上使用，不在通用技术术语上使用。

**HTML:**
```html
<p>The project uses a
  <span class="term" data-definition="在 DDD 中，聚合根是一组相关对象的入口点。外部只能通过聚合根访问聚合内的对象，保证业务规则的一致性。">Aggregate Root</span>
  to enforce domain invariants.
</p>
```

**Rules:**
- 只标注项目特有的概念、非主流框架 API、领域术语
- 不标注通用技术概念（CRUD、ORM、MVC、DI 等）
- 定义应简洁：概念在这个项目中的含义 + 为什么要用它
- 用 `cursor: pointer`，不用 `cursor: help`

---

## Flow Diagrams

静态流程图，用于展示线性流程。

```html
<div class="flow-steps">
  <div class="flow-step">
    <div class="flow-step-num">1</div>
    <p>HTTP Request</p>
  </div>
  <div class="flow-arrow">&rarr;</div>
  <div class="flow-step">
    <div class="flow-step-num">2</div>
    <p>Controller</p>
  </div>
  <div class="flow-arrow">&rarr;</div>
  <div class="flow-step">
    <div class="flow-step-num">3</div>
    <p>Service</p>
  </div>
</div>
```

---

## Permission/Config Badges

标注配置项和权限。

```html
<div class="badge-list">
  <div class="badge-item">
    <code class="badge-code">spring.datasource.url</code>
    <span class="badge-desc">Database connection string (MySQL in prod, H2 in tests)</span>
  </div>
  <div class="badge-item">
    <code class="badge-code">spring.cache.type</code>
    <span class="badge-desc">Cache provider: redis for production, none for local dev</span>
  </div>
</div>
```
