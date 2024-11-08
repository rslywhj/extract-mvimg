# extract-mvimg
顾名思义，从MVIMG照片中提取照片与视频文件（使用小米动态照片测试，理论上兼容符合MVIMG标准的其他照片）

## 适合Windows PowerShell使用的脚本
  依赖于 exiftool 运行，请先安装好 [exiftool](https://exiftool.org/)。
## 使用方法：
    1.打开Windows Powershell
    2.cd 到脚本所在路径
    3.输入./extract-mvimg.ps1 "MVIMG照片所在路径"
    4.回车运行，将在脚本目录输出转换后的照片和视频
***
注意Windows 系统默认设置可能不允许运行某些脚本以确保安全性您可以通过以下步骤允许脚本执行：
### 方法 1：修改执行策略
1. **以管理员身份运行 PowerShell**  
   - 在 Windows 搜索框中输入 `powershell`，右键点击 `Windows PowerShell`，选择 **以管理员身份运行**。

2. **检查当前执行策略**  
   输入以下命令并按 Enter：
   ```powershell
   Get-ExecutionPolicy
   ```
   默认情况下，它通常会显示 `Restricted`。

3. **更改执行策略**  
   输入以下命令以允许脚本执行：
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```
   这个命令会允许本地脚本运行，并且只允许来自互联网的脚本，如果它们有有效的签名。

4. **确认更改**  
   系统会询问是否确认更改，输入 `Y` 并按 Enter。

### 方法 2：只为当前用户更改执行策略
如果您不想更改系统级别的设置，可以只为当前用户更改执行策略：

1. 打开 **PowerShell** 以管理员身份。
2. 输入以下命令：
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. 确认更改，输入 `Y`。

### 方法 3：临时允许脚本运行
如果您不想永久更改执行策略，可以在 PowerShell 中临时允许脚本运行。执行以下命令后，您可以运行脚本，脚本执行完毕后，策略会恢复原状：

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

这样您就可以运行 `extract-mvimg.ps1` 脚本
