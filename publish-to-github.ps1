param(
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "没有找到 Git。请先安装 Git for Windows：https://git-scm.com/download/win"
}

if (-not (Test-Path ".git")) {
    git init
}

if (-not (git config user.name)) {
    git config user.name "BuJiuJie Builder"
}
if (-not (git config user.email)) {
    git config user.email "builder@local.invalid"
}

git add .
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Build BuJiuJie iOS app"
} else {
    Write-Host "没有新的文件需要提交，继续上传。"
}

git branch -M main
$existingRemote = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0 -and $existingRemote) {
    git remote set-url origin $RepoUrl
} else {
    git remote add origin $RepoUrl
}

git push -u origin main
if ($LASTEXITCODE -ne 0) {
    throw "上传失败。请确认仓库地址正确，并在弹出的登录窗口中登录 GitHub。"
}

Write-Host ""
Write-Host "上传完成。GitHub Actions 正在生成 IPA。"
Write-Host "打开仓库网页 -> Actions -> Build unsigned IPA -> 下载构建产物。"

