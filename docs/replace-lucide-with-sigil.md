# 用 sigil 替换 lucide 依赖

> 结论:**可以替换**。本文是落地计划。所有技术假设都已用 `sigil` 在 scratch 目录实跑验证(命名、产物形态、self-contained、41 个图标全部 upstream 命中)。

## 1. 现状(替换前)

| 项 | 现状 |
| --- | --- |
| 依赖 | `site/package.json` → `lucide@^1.17.0`(devDep)+ `icons:generate` 脚本 |
| 生成器 | `site/scripts/generate-lucide-icons.mjs`(~178 行):扫描 `src` 中的 import,从 `lucide` 包取节点数据,生成 `site/src/lib/lucide-icons.tsrx`(~1570 行,41 个图标) |
| 产物 | 单文件、self-contained,每个图标一个导出函数,名字是 lucide PascalCase(`ChevronDown`、`X`、`Github`…) |
| 用量 | 41 个图标,跨约 30 个 `.tsrx` 文件;**只用到 `class` 和 `size` 两个 prop** |
| 手工特例 | 脚本内硬编码了 `Github` override(lucide 已废弃 brand 图标,包里取不到) |

### 必须保住的两个集成点
1. **StackBlitz `?raw` 内联**:`site/src/components/open-in-stackblitz.tsrx` 用 `import lucideIcons from '../lib/lucide-icons.tsrx?raw'`,把整份文件原样塞进 StackBlitz 项目(`src/lib/lucide-icons.tsrx`)。→ **要求生成文件必须 self-contained(无跨文件 import)**。
2. **路径改写**:`site/src/lib/get-component-code.ts:24` 把 demo 里的 `../../lib/lucide-icons.tsrx` 改写成 `./lib/lucide-icons.tsrx`。

> 已确认:**没有任何 CSS 依赖 `.lucide` / `.lucide-icon` 等类名**(全项目只在生成文件内部出现),`color` / `strokeWidth` / `absoluteStrokeWidth` / `title` 这些 prop **没有任何调用点使用**。删掉它们零风险。

## 2. 为什么 sigil 合适(已验证)

- `sigil etch --output … --jsx tsrx` 产出**单一 self-contained 模块**(无 `import`)→ `?raw` 内联与路径改写**完全不用改**。
- 视觉**逐像素一致**:`viewBox="0 0 24 24"`、`stroke="currentColor"`、`stroke-width="2"`、round caps,与 lucide 同源(ISC)。
- `icons.json`(~45 行清单)取代 178 行脚本;vendor 缓存在 `node_modules/.icons`(gitignore 覆盖),fresh checkout 自动重新 vendor,像 `pnpm install`。
- 提交物只剩 `icons.json` + 生成文件,生成器脚本与 `lucide` 运行依赖都可删除。

sigil 产物形态(实跑样例):
```tsx
export type IconProps = { size?: number | string; [attr: string]: unknown }
export function LuChevronDown(&{ size, ...props }: IconProps) {
  return (<svg xmlns="…" width={size ?? '1em'} height={size ?? '1em'} viewBox="0 0 24 24" {...props}>
    <g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="m6 9 6 6 6-6" /></g></svg>)
}
```

## 3. 三个需要拍板的差异(及建议)

### 3.1 命名前缀是强制的 ⚠️(主要改动来源)
sigil 永远给库加前缀(lucide→`Lu`),`prefix: ""` 被显式拒绝(*"must start with an uppercase letter"*)。所以 **`ChevronDown` 拿不到裸名**,必然变成 `LuChevronDown`。两种吸收方式:

- **方案 A(推荐)— 全量重命名**:用 ast-grep 做有作用域的 codemod,import 与 JSX 标签一起改成 `Lu*` / `Si*`。结果干净、符合 sigil 习惯(`import { LuX } from …`、`<LuX/>`)。
- **方案 B — import 处别名**:`import { LuX as X, LuCheck as Check } from './lib/lucide-icons.tsrx'`,JSX 用法一字不改,只动约 30 行 import。改动最小、风险最低,但留下别名噪音。

> 两方案对 `?raw` 都安全:StackBlitz 内联的是生成文件本身(导出 `LuX`),demo 代码原样发出去,名字能对上。
> **重命名时务必有作用域**:`X`、`Check`、`Code`、`File`、`Search`、`Play`、`Info`、`Settings` 等是常见词,全局替换会误伤无关标识符——只在「import 自 `lucide-icons.tsrx` 的文件」内,针对 import specifier 和 `<Name …`/`<Name/>` 标签替换。

### 3.2 `github` 在 lucide 已废弃
`sigil search github --set lucide` 查无此图标(正是原脚本要硬编码 override 的原因)。替代:
- **建议用 `simple-icons/github`** → 组件 `SiGithub`,`fill="currentColor"`,跟随文字色。导航里那一个 `<Github class="h-4 w-4"/>` 换成它即可。
- 代价:由 lucide 的**描边** octocat 变成 simple-icons 的**实心** GitHub mark(更标准、更易识别,可接受)。
- 这会让清单多声明一个库 `simple-icons`,但 etch 仍是**同一个 self-contained 文件**(`Lu*` 与 `Si*` 共存),`?raw` 不受影响。

### 3.3 默认尺寸 24 → 1em
sigil 默认 `width/height = size ?? '1em'`(原脚本默认 24)。带 `class`(`h-4 w-4`)或显式 `size={16}` 的用法不受影响;但**裸用 `<ChevronDown/>` / `<X/>` / `<Check/>`(无 class 无 size)的图标会从 24px 缩到 1em**。这类裸用法分布在:`select`、`number-input`、`menu`、`nested-menu`、`pagination`、`carousel`、`combobox`、`date-picker`、`dialog`、`popover`、`file-upload`、`floating-panel`、`tags-input`、`clipboard` 等 demo。
> 处理:迁移后逐一目检这些 demo;偏小则补 `class="size-6"`(=24px)或显式 `size={24}`。`1em` 多数在按钮/触发器内反而更协调,通常可直接接受。

## 4. 图标映射(40 lucide + 1 simple-icons)

当前名 → sigil ref(lucide 部分一律 `kebab-case`,组件名 = `Lu` + 当前名):
```
arrow-down-left arrow-left arrow-right bold calendar-days check chevron-down
chevron-left chevron-right chevrons-up-down chevron-up circle-alert clipboard-copy
code code-xml copy external-link eye eye-off file file-text folder info italic
keyboard loader maximize-2 minus moon pipette play rotate-ccw search settings
sparkles sun triangle-alert underline x zap
```
`Github` → **`simple-icons/github`**(组件 `SiGithub`)。

> 已实跑 `sigil add`(40+1)+ `sigil etch --jsx tsrx`:**41 个全部命中,无 upstream 缺失**,产出单文件、无跨文件 import。

## 5. 执行步骤

> 全程在 `site/` 下操作,改动只触及 `site/`。

**0. 前置**:确认 `sigil --schema` 可用。

**1. 建清单**
```bash
cd site
sigil use lucide simple-icons
sigil add 'lucide/arrow-down-left+arrow-left+arrow-right+bold+calendar-days+check+chevron-down+chevron-left+chevron-right+chevrons-up-down+chevron-up+circle-alert+clipboard-copy+code+code-xml+copy+external-link+eye+eye-off+file+file-text+folder+info+italic+keyboard+loader+maximize-2+minus+moon+pipette+play+rotate-ccw+search+settings+sparkles+sun+triangle-alert+underline+x+zap,simple-icons/github'
```
提交 `site/icons.json`。

**2. 改接线**
- `site/package.json`:`icons:generate` 改为
  `sigil etch --output src/lib/lucide-icons.tsrx --jsx tsrx`(输出路径不变 → `?raw`、路径改写无需动)。
- 删除 `site/scripts/generate-lucide-icons.mjs`。
- 从 `site/package.json` devDependencies 移除 `lucide`。
- 确认 `node_modules/.icons` 已被 gitignore 覆盖(在 `node_modules` 下,通常已覆盖)。

**3. 生成**:`bun run icons:generate`(覆盖 `src/lib/lucide-icons.tsrx`)。

**4. 吸收命名差异**(选 §3.1 方案 A 或 B):
- 全部 `lucide/*` 用法:`ChevronDown→LuChevronDown` … (统一前缀 `Lu`)。
- 导航处 `Github → SiGithub`。
- 方案 A 用 ast-grep 有作用域改写;方案 B 只改 import 行加 `as` 别名。

**5. 验证**
```bash
cd site
rg -n "lucide" .                 # 应只剩生成文件头注释/path 改写,无 import lucide 包
bun run build                     # 或 tsc / vite build,确认无未定义标识符
```
- 目检 §3.3 列出的裸尺寸图标 + 导航 GitHub 图标。
- 打开任一 demo 的 "Open in StackBlitz",确认 `?raw` 内联包能编译运行(回归 self-contained 集成)。

**6. 同步文档**
- `AGENTS.md:16`:把 `generate-lucide-icons.mjs` 那条改成「`icons.json` + `sigil etch` 生成 `lucide-icons.tsrx`」。
- `.agents/skills/sync-latest/references/upgrade-playbook.md:45-52`:更新图标小节——生成命令、`git diff` 关注 `icons.json` 而非 `.mjs`。

## 6. 风险与回滚

- **风险点**:命名 codemod 误伤(§3.1,用 ast-grep 限定作用域规避)、裸尺寸视觉缩小(§3.3,目检补尺寸)、GitHub 由描边变实心(§3.2,设计可接受)。
- **API**:仅 `class`+`size` 在用,sigil 全支持;丢弃的 prop/class 无人使用,零风险。
- **回滚**:改动集中在 `site/`,`git revert` 即可;`icons.json` 与生成文件可重复 `sigil etch` 幂等重建。

## 7. 收益

- 删除 ~178 行自维护生成器 + 一个运行期依赖,换成 ~45 行声明式 `icons.json`。
- 去掉 `Github` 硬编码 override(改用上游 simple-icons)。
- 后续加图标:`sigil add lucide/<name>` + `bun run icons:generate`,无需碰脚本逻辑。
- 未来要 brand logo / 其它图标库,`sigil use <set>` 即可,统一管线。
