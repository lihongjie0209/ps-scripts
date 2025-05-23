## 说明

一些常用的ps脚本



## 文档

### hyperv.ps1

#### 功能
用于在 Windows 10 及以上系统上启用或禁用 Hyper-V 功能。

#### 使用方法

1. **以管理员身份运行 PowerShell**
2. 执行脚本并传递参数：

    ```powershell
    # 启用 Hyper-V
    hyperv.ps1 -action enable

    # 禁用 Hyper-V
    hyperv.ps1 -action disable

    ```




### 7z.ps1

#### 功能
用于下载并安装 7-Zip。脚本支持自定义下载链接、安装路径和日志文件位置。

#### 使用方法

1. **以管理员身份运行 PowerShell** (如果安装到 Program Files 或其他受保护目录，或者需要修改系统 PATH)
2. 执行脚本并传递参数：

    ```powershell
    # 使用默认设置下载并安装 7-Zip
    .\7z.ps1

    # 指定下载链接、安装路径和日志文件
    .\7z.ps1 -DownloadUrl "https://www.7-zip.org/a/7zxxxx-x64.exe" -InstallPath "C:\Tools\7-Zip" -LogFile "C:\logs\7zip_install.log"
    ```

#### 参数说明

*   `-DownloadUrl`: (可选) 7-Zip 安装程序的下载链接。默认为官方最新版64位链接。
*   `-InstallPath`: (可选) 7-Zip 的安装目录。默认为 `"$env:ProgramFiles\7-Zip"`。
*   `-LogFile`: (可选) 日志文件的完整路径。默认为 `"$env:TEMP\7zip_install.log"`。
