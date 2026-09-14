# ShareX 接入

这个项目只使用 GitHub，因此 ShareX 通过本地 PowerShell 脚本调用 GitHub Contents API。Token 不会放进公开网页或仓库。

## 1. 设置 Token

创建只允许访问 `lingwangshu018/image`、仅具有 **Contents: Read and write** 权限的 Fine-grained personal access token。

在 Windows 用户环境变量中保存：

```powershell
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', '你的 Token', 'User')
```

设置后完全退出并重新打开 ShareX。不要把带有真实 Token 的命令、截图或配置发给其他人。Token 泄露后应立即在 GitHub 撤销。

## 2. 先测试脚本

在 PowerShell 中运行：

```powershell
& '.\tools\sharex-upload.ps1' -File 'C:\path\to\image.png' -Folder illustrations
```

成功时标准输出只有一条 jsDelivr 图片直链；失败时会返回非零退出码并在错误流说明原因。

完整 JSON 输出可直接调用：

```powershell
& '.\tools\github-upload.ps1' -File 'C:\path\to\image.png' -Folder illustrations
```

要覆盖固定名称，必须明确指定名称和覆盖开关：

```powershell
& '.\tools\github-upload.ps1' -File 'C:\path\to\avatar.png' -Folder avatars -Name 'avatar.png' -Overwrite
```

默认不覆盖，而是生成唯一 ASCII 文件名，避免 CDN 缓存和 Git 冲突。

## 3. 配置 ShareX

不同 ShareX 版本对“外部程序上传”入口的命名可能不同。创建一个上传后的自定义动作或工作流，使用：

- 程序：`powershell.exe`
- 参数：

```text
-NoProfile -ExecutionPolicy Bypass -File "C:\Users\Thnikpad\Downloads\image-main\tools\sharex-upload.ps1" -File "$input" -Folder illustrations
```

其中 `$input` 应替换为该 ShareX 版本提供的“当前截图文件路径”变量。让 ShareX 捕获程序标准输出，并把它复制到剪贴板。

ShareX Custom Uploader 本身通常不能可靠完成 GitHub Contents API 所需的文件 Base64 JSON 和覆盖前 SHA 查询，因此这里使用本地适配脚本，不配置不存在的 GitHub Pages `/api/upload` 地址。

## 4. 输出地址

默认输出：

```text
https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/illustrations/example.png
```

上传后立即访问若尚未刷新，可从 `github-upload.ps1` 的 JSON 中使用 `rawUrl`。需要永久锁定某次内容时使用 `stableUrl`（带 commit SHA）。
