---
kind: external_dependency
name: Blowfish Hugo 主题
slug: blowfish
category: external_dependency
category_hints:
    - framework_behavior
scope:
    - '**'
---

### Blowfish
- 作为 Hugo 主题以 git submodule 形式引入（`.gitmodules`），站点不直接修改主题目录，所有定制通过 `layouts/partials/` 覆盖与 `assets/css/custom.css` 注入。
- 主题参数集中在 `config/_default/params.toml`，可调项包括首页布局（profile/hero/card/landing）、配色方案（colorScheme/defaultAppearance/autoSwitchAppearance）、背景图与社交分享图、作者信息等。
- 站点对主题的覆盖点：`layouts/partials/footer.html`（zoom 兼容修复、mermaid 渲染）、`layouts/partials/extend-footer.html`（代码块语言标签栏注入）、`layouts/partials/article-meta/`、`layouts/partials/toc.html`、`layouts/partials/related.html`。