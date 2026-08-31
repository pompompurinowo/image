# GitHub 通用图床

这是一个只使用 GitHub 的图片仓库和上传工具，适用于：

- 聊天软件中的图片链接
- Markdown、论坛和 BBCode
- 网页 `<img>` / CSS
- ShareX
- PowerShell、curl 和自制程序

GitHub 仓库负责存储，GitHub Contents API 负责上传，jsDelivr 提供默认公开直链。GitHub Pages 是静态网站，不是上传服务器。

## 在线上传工具

打开：

```text
https://pompompurinowo.github.io/image/
```

网页工具可以批量转换、压缩和上传图片，并生成四种地址：

| 地址 | 用途 |
|---|---|
| jsDelivr `@main` | 默认公开直链，适合网页、论坛和软件 |
| jsDelivr `@commit-sha` | 内容不会随分支更新，适合固定发布版本 |
| GitHub Raw | CDN 尚未刷新时的备用地址 |
| GitHub Pages | 第二备用静态地址 |

网页还可直接复制 Markdown、HTML、BBCode 或全部链接。

## 格式兼容性

默认选择“自动兼容”：

- 含透明通道的图片输出 PNG。
- 其他图片输出 JPG。
- WebP 仍可手动选择，适合现代网页，但部分聊天软件和旧程序不预览 WebP。

如果图片在浏览器地址栏能打开、在其他软件中却不显示，先改用 JPG/PNG，而不是 WebP。

推荐设置：

- 照片、壁纸：自动兼容或 JPG，画质 88，最长边 2000 px。
- 透明图标：自动兼容或 PNG。
- 现代网页且重视体积：WebP。
- 默认使用唯一英文名，避免中文路径兼容问题和 CDN 旧缓存。

## 第一次使用：创建 GitHub Token

上传者需要自己的 **Fine-grained personal access token**：

1. 打开 GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens。
2. Repository access 选择 **Only select repositories**。
3. 只选择 `pompompurinowo/image`。
4. Repository permissions 中只把 **Contents** 设置为 **Read and write**。
5. 设置合理的过期时间并复制 Token。

网页中的 Token：

- 只保存在当前页面内存中。
- 不写入 `localStorage`、`sessionStorage`、Cookie、URL 或仓库。
- 只发送到 `https://api.github.com`。
- 刷新或关闭页面后清空。

请只在官方 GitHub Pages HTTPS 地址输入 Token。Token 相当于仓库写入钥匙；泄露后立即在 GitHub 撤销并重新创建。

## 网页上传流程

1. 打开在线上传工具。
2. 填入 Token，点击“测试连接”。
3. 拖入图片。
4. 选择格式、最长边、画质、命名方式和目录。
5. 点击“开始转换”。
6. 检查输出格式和大小。
7. 点击“上传全部到 GitHub”。
8. 上传完成后复制所需格式的链接。

默认生成唯一文件名，不会覆盖已有图片。主动选择固定名称并覆盖图片时，jsDelivr `@main` 可能暂时显示旧缓存；公开发布建议换文件名，或使用新提交的稳定链接。

## 图片直链

假设仓库路径为：

```text
backgrounds/night-beach.jpg
```

默认 jsDelivr 地址：

```text
https://cdn.jsdelivr.net/gh/pompompurinowo/image@main/backgrounds/night-beach.jpg
```

GitHub Raw 备用：

```text
https://raw.githubusercontent.com/pompompurinowo/image/main/backgrounds/night-beach.jpg
```

GitHub Pages 备用：

```text
https://pompompurinowo.github.io/image/backgrounds/night-beach.jpg
```

不要使用下面这种 GitHub 页面地址作为图片直链：

```text
https://github.com/pompompurinowo/image/blob/main/backgrounds/night-beach.jpg
```

`blob` 地址返回的是 HTML 页面，部分软件无法读取。`raw.gitcode.com` 可作为国内可选镜像，但它的同步和响应不由本仓库控制，不作为默认地址。

## 在 Markdown、论坛和网页中使用

Markdown：

```markdown
![夜景](https://cdn.jsdelivr.net/gh/pompompurinowo/image@main/backgrounds/night-beach.jpg)
```

HTML：

```html
<img src="https://cdn.jsdelivr.net/gh/pompompurinowo/image@main/backgrounds/night-beach.jpg" alt="夜景">
```

CSS：

```css
.phone-wallpaper {
  background-image: url("https://cdn.jsdelivr.net/gh/pompompurinowo/image@main/backgrounds/night-beach.jpg");
}
```

BBCode：

```text
[img]https://cdn.jsdelivr.net/gh/pompompurinowo/image@main/backgrounds/night-beach.jpg[/img]
```

## PowerShell 本地上传

Windows 本地客户端位于 `tools/github-upload.ps1`。它会读取 `GITHUB_TOKEN` 环境变量，不在脚本中保存 Token。

设置用户环境变量：

```powershell
[Environment]::SetEnvironmentVariable('GITHUB_TOKEN', '你的 Token', 'User')
```

重新打开 PowerShell 后上传：

```powershell
& '.\tools\github-upload.ps1' -File 'C:\path\to\image.png' -Folder illustrations
```

成功时输出一行 JSON，包含：

- `url`：默认 jsDelivr 链接
- `stableUrl`：commit SHA 稳定链接
- `rawUrl`：GitHub Raw 备用链接
- `pagesUrl`：GitHub Pages 备用链接
- `markdown` 和 `html`

固定名称并明确覆盖：

```powershell
& '.\tools\github-upload.ps1' -File 'C:\path\to\avatar.png' -Folder avatars -Name 'avatar.png' -Overwrite
```

脚本默认拒绝超过 20 MB 的文件。GitHub Contents API 和 Git 仓库不适合作为大文件存储。

## curl / 程序调用

GitHub-only 模式的真实上传接口是 GitHub Contents API，不存在安全的匿名 `/api/upload`：

```text
GET https://api.github.com/repos/pompompurinowo/image/contents/{path}?ref=main
PUT https://api.github.com/repos/pompompurinowo/image/contents/{path}
```

请求头：

```text
Accept: application/vnd.github+json
Authorization: Bearer <GITHUB_TOKEN>
X-GitHub-Api-Version: 2022-11-28
Content-Type: application/json
```

新文件 PUT 请求体：

```json
{
  "message": "upload: illustrations/example.png",
  "content": "<文件的 Base64 内容>",
  "branch": "main"
}
```

覆盖文件前必须先 GET 取得当前 `sha`，再把它加入 PUT 请求体。建议程序默认生成唯一文件名，以省去覆盖查询并避免 CDN 缓存。

网页前端可以调用相同接口，但必须由使用者输入自己的 Token。不能把共享 Token 写入公开 JavaScript，否则任何访问者都能提取并滥用它。

## ShareX

ShareX 使用本地适配脚本，详细步骤见 [tools/sharex-setup.md](tools/sharex-setup.md)。

脚本入口：

```powershell
& '.\tools\sharex-upload.ps1' -File 'C:\path\to\image.png' -Folder illustrations
```

成功时标准输出只有图片直链，便于 ShareX 捕获并复制到剪贴板。

## 仓库目录

```text
image/
├─ avatars/          # 头像
├─ backgrounds/      # 壁纸、背景图
├─ icons/            # 图标
├─ illustrations/    # 插画、立绘
├─ stickers/         # 贴纸、表情
└─ tools/
   ├─ image-converter.html
   ├─ github-upload.ps1
   ├─ sharex-upload.ps1
   └─ sharex-setup.md
```

## 常见问题

**网页能打开，聊天软件不显示**

确认链接返回的是 JPG/PNG，且不是 GitHub `blob` 页面。部分平台也会阻止外部图片预览，但仍可通过浏览器打开链接。

**刚上传后 jsDelivr 返回 404 或旧图片**

等待 CDN 刷新，临时使用 Raw 备用链接。更新已有图片时最好换新文件名。

**401**

Token 无效或已过期。

**403**

Token 权限不足、GitHub 限流或组织策略阻止。确认仅目标仓库的 Contents 为 Read and write。

**409**

同一文件被并发修改。网页和 PowerShell 工具会重新读取 SHA 后重试一次。

**422**

文件路径、内容、分支或请求参数无效。

## 安全边界

GitHub Pages 只能托管静态文件，不能隐藏服务器密钥，也不能实现匿名上传后端。只使用 GitHub 时，通用方案是：

- 每位上传者持有自己的最小权限 PAT。
- 网页或本地客户端直接调用 GitHub Contents API。
- 仓库中的图片通过 jsDelivr、Raw 或 Pages 公开读取。

任何把全局 Token 写进网页源码、ShareX 公共配置或仓库文件的方案都不安全。
