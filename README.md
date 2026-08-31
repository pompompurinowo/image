# 图片仓库

这是一个用于存放网页、油猴脚本和其他项目静态图片资源的公共仓库。

图片上传到这里以后，可以通过 **jsDelivr CDN** 生成公开访问链接。

#图使用
国内网站：https://raw.gitcode.com/lingwangshu018/image/raw/main/
本网站：https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/

## 直接打开图片转换器

GitHub Pages：

```text
https://lingwangshu018.github.io/image/
```

打开后会直接进入图片转换器。

---

## 目录

```text
image/
├─ avatars/          # 头像
├─ backgrounds/      # 壁纸、背景图
├─ icons/            # 图标
├─ illustrations/    # 插画、立绘
├─ stickers/         # 贴纸、表情
└─ tools/            # 图片处理小工具
```

这些目录已经放入 `.gitkeep`，因此即使暂时没有图片，GitHub 也会保留并显示文件夹。

---

## 第一次使用：准备 GitHub Token

转换器支持把转换后的图片直接上传到本仓库，因此第一次使用需要创建一个 GitHub Token。

推荐创建 **Fine-grained personal access token**，并只授权这个 `image` 仓库，不要使用权限过大的 Token。

建议设置：

1. GitHub → Settings → Developer settings。
2. 打开 Personal access tokens → Fine-grained tokens。
3. 新建 Token。
4. Repository access 选择 **Only select repositories**。
5. 只选择 `lingwangshu018/image`。
6. Repository permissions 中把 **Contents** 设置为 **Read and write**。
7. 创建后复制 Token。

> Token 相当于仓库上传钥匙，不要发给别人，也不要截图公开。

转换器中的 Token：

- 只在当前浏览器页面内存中使用。
- 不会写入仓库。
- 不会保存到 `localStorage`。
- 刷新或关闭页面后需要重新填写。

打开转换器后，把 Token 粘贴进去，点击 **测试连接**。看到“连接成功”后即可使用自动上传。

---

## 日常使用：转换并自动上传

推荐设置：

- 壁纸 / 插画 / 照片：`WebP`，画质 `85`
- 透明图标：优先 `WebP`；需要 PNG 时选择 `PNG`
- 最长边：一般 `2000px`
- 文件名：推荐英文、数字和短横线

操作：

1. 打开 `https://lingwangshu018.github.io/image/`。
2. 填入 GitHub Token，并点击 **测试连接**。
3. 把图片拖进转换器。
4. 选择输出格式、尺寸、画质。
5. 选择上传目录，例如 `backgrounds`、`icons`、`avatars`。
6. 点击 **开始转换**。
7. 检查转换结果。
8. 点击 **上传全部到 GitHub**。
9. 上传成功后，图片旁边会显示 CDN 地址。
10. 点击 **复制 CDN** 即可使用。

如果仓库中已经存在同目录、同文件名的图片，转换器会自动更新该文件。

---

## CDN 地址规则

本仓库 jsDelivr CDN 基础地址：

```text
https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/
```

例如：

```text
backgrounds/night-beach.webp
```

对应：

```text
https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/backgrounds/night-beach.webp
```

又例如：

```text
icons/wechat.webp
```

对应：

```text
https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/icons/wechat.webp
```

转换器会自动生成这些地址，不需要手动拼接。

---

## 在油猴脚本 / 网页中使用

推荐只写一次基础地址：

```js
const IMAGE_CDN = 'https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/';
```

然后：

```js
const nightBeach = IMAGE_CDN + 'backgrounds/night-beach.webp';
const wechatIcon = IMAGE_CDN + 'icons/wechat.webp';
```

HTML：

```html
<img src="https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/icons/wechat.webp" alt="微信图标">
```

CSS：

```css
.phone-wallpaper {
  background-image: url('https://cdn.jsdelivr.net/gh/lingwangshu018/image@main/backgrounds/night-beach.webp');
}
```

---

## 文件名建议

推荐：

```text
night-beach.webp
lion-birthday.webp
wechat.webp
summer-room-01.webp
```

尽量避免非常长、包含大量符号的文件名。

中文文件名可以使用，但 CDN 地址会自动变成 URL 编码，例如 `%E5%A3%81...`，这是正常现象。

---

## 图片更新与缓存

jsDelivr 会缓存文件。

如果一张已经公开使用的图片内容发生明显变化，推荐换新文件名：

```text
night-beach-v2.webp
```

而不是反复覆盖：

```text
night-beach.webp
```

这样可以避免 GitHub 已更新、CDN 暂时仍显示旧图的情况。

---

## 最简单的流程

```text
打开图片转换器
 ↓
拖入原图
 ↓
转换为 WebP / PNG
 ↓
选择 backgrounds / icons / avatars 等目录
 ↓
上传全部到 GitHub
 ↓
复制自动生成的 CDN 地址
 ↓
放进网页或油猴脚本
```
