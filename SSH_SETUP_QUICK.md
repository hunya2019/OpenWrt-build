# 快速参考：SSH公钥配置

## 🔴 错误信息
```
Error: No public SSH keys registered with hunya2019's GitHub profile
```

## ✅ 解决方案

### 1️⃣ 检查是否已有SSH密钥

**Windows PowerShell:**
```powershell
Test-Path $env:USERPROFILE\.ssh\id_ed25519.pub
# 或检查RSA密钥
Test-Path $env:USERPROFILE\.ssh\id_rsa.pub
```

**Linux/Mac:**
```bash
ls -la ~/.ssh/
```

---

### 2️⃣ 生成SSH密钥对（如需要）

**推荐：ED25519（更快更安全）**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**备用：RSA 4096位**
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**提示：**
- 按Enter保存到默认位置
- 可选：设置密钥密码（按Enter则无密码）

---

### 3️⃣ 查看并复制公钥

**Windows PowerShell:**
```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
# 或 id_rsa.pub 如果使用了RSA
```

**Linux/Mac:**
```bash
cat ~/.ssh/id_ed25519.pub
# 或 id_rsa.pub
```

**输出示例：**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbCd... your_email@example.com
```

---

### 4️⃣ 在GitHub中添加公钥

1. **访问设置：** https://github.com/settings/keys

2. **点击：** "New SSH key" 按钮

3. **填写表单：**
   - **Title:** `GitHub Actions SSH` 或任意名称
   - **Key type:** 选择 `Authentication Key`
   - **Key:** 粘贴刚才复制的公钥内容

4. **点击：** "Add SSH key"

5. **验证：** GitHub会发送确认邮件（如配置了）

---

### 5️⃣ 验证SSH配置

**本地测试SSH连接：**
```bash
ssh -T git@github.com
```

**预期输出：**
```
Hi hunya2019! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 🎯 关键步骤速查表

| 步骤 | Windows PowerShell | Ubuntu/macOS |
|------|-------------------|------------|
| 生成密钥 | `ssh-keygen -t ed25519 -C "email"` | `ssh-keygen -t ed25519 -C "email"` |
| 查看公钥 | `Get-Content ~/.ssh/id_ed25519.pub` | `cat ~/.ssh/id_ed25519.pub` |
| 测试连接 | `ssh -T git@github.com` | `ssh -T git@github.com` |

---

## ℹ️ 关于SSH密钥

- **id_ed25519** - 新推荐格式，更快更小
- **id_rsa** - 传统格式，兼容性更好
- **公钥 (.pub)** - 分享给GitHub，用于验证身份
- **私钥 (无后缀)** - 保密存放在本地，用于签名和加密

---

## 🚀 完成后

配置完成SSH公钥后：

1. 提交当前修改到GitHub
2. 重新运行Workflow
3. 勾选 `ssh: true` 即可启用SSH调试

---

## 💬 故障排查

| 问题 | 检查项 |
|------|--------|
| 文件不存在 | 确认是否生成了密钥，检查路径是否正确 |
| GitHub不识别 | 确保复制的是 `.pub` 公钥文件，不是私钥 |
| 权限错误 | 确保私钥文件权限为 `600`：`chmod 600 ~/.ssh/id_ed25519` |
| 无法连接 | 检查网络，或尝试 `ssh -vT git@github.com` 调试 |

---

## 📚 相关资源

- [GitHub SSH文档](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [SSH密钥生成指南](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
