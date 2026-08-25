# 检查 content/posts 下所有文章 front matter 是否包含必填字段且非空
# 用法: powershell -File scripts/check-frontmatter.ps1

$required = @{
  slug        = '英文 slug，用于生成英文 URL（缺失时 URL 回退为中文文件名）'
  description = '文章描述（SEO 约定）'
  categories  = '分类'
  tags        = '标签'
}

$postsDir = Join-Path $PSScriptRoot '..\content\posts'
$posts = Get-ChildItem $postsDir -Filter *.md -File
if ($posts.Count -eq 0) { Write-Host '未找到任何文章'; exit 1 }

$errors = @()
foreach ($p in $posts) {
  $raw = Get-Content $p.FullName -Raw
  $m = [regex]::Match($raw, '(?s)^\+\+\+\r?\n(.*?)\r?\n\+\+\+')
  if (-not $m.Success) { $errors += "$($p.Name): 缺少 front matter"; continue }
  $fm = $m.Groups[1].Value
  foreach ($k in $required.Keys) {
    $val = [regex]::Match($fm, "(?m)^$k\s*=\s*(.*)$").Groups[1].Value.Trim()
    $val = $val.Trim("'`" ")  # 去掉引号与空白，'' 视为空
    if (-not $val -or $val -eq '[]') {
      $errors += "$($p.Name): $k 缺失或为空（$($required[$k])）"
    }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "检查未通过（$($errors.Count) 处问题）：" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  exit 1
} else {
  Write-Host "检查通过：$($posts.Count) 篇文章均包含全部必填字段" -ForegroundColor Green
}
