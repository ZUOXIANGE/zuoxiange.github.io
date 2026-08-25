# 启用仓库内的 git hooks（.githooks/），在仓库根目录执行一次即可
# 用法: pwsh -NoProfile -File scripts/setup-hooks.ps1
git config core.hooksPath .githooks
Write-Host "Git hooks enabled: core.hooksPath = $(git config core.hooksPath)"
