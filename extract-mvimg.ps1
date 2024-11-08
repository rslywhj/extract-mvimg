#从MVIMG照片中分离照片与视频
#by DouglasLee 2024-10-06
param (
    [string]$inputPath
)

# 处理单个 MVIMG 文件的函数
function Process-MVIMG {
    param (
        [string]$file
    )

    # 获取脚本所在目录路径
    $scriptPath = $PSScriptRoot

    # 创建唯一文件名以避免文件冲突的函数
    function Get-Unique-FileName($baseFilePath, $extension) {
        $i = 1
        $newFilePath = "$baseFilePath$extension"
        while (Test-Path $newFilePath) {
            $newFilePath = "$baseFilePath-$i$extension"
            $i++ 
        }
        return $newFilePath
    }

    # 设置用于创建唯一文件名的基本文件名
    $baseFileName = [System.IO.Path]::Combine($scriptPath, [System.IO.Path]::GetFileNameWithoutExtension($file))
    $newImageFile = Get-Unique-FileName $baseFileName "_image.jpg"
    $newVideoFile = Get-Unique-FileName $baseFileName ".mp4"

    # 获取输入文件的大小
    $fileSize = (Get-Item $file).Length

    # 使用 exiftool 读取 Micro Video Offset 值
    $exifOutput = & exiftool -MicroVideoOffset $file
    if (-not $exifOutput) {
        Write-Host "无法从 $file 中提取 Micro Video Offset，跳过此文件"
        return
    }

    if ($exifOutput -match "Micro Video Offset\s*:\s*(\d+)") {
        $offset = [int]$matches[1]
    } else {
        Write-Host "在 $file 中找不到 Micro Video Offset，跳过此文件"
        return
    }

    # 计算视频部分的起始偏移量
    $startOffset = $fileSize - $offset
    Write-Host "处理 $file，视频起始偏移 $startOffset"

    try {
        # 打开输入文件并提取图像部分
        $inputStream = [System.IO.File]::OpenRead($file)
        $imageBuffer = New-Object byte[] $startOffset
        $inputStream.Read($imageBuffer, 0, $startOffset) | Out-Null
        [System.IO.File]::WriteAllBytes($newImageFile, $imageBuffer)
        Write-Host "提取图像部分并将其保存为 $newImageFile"

        # 提取视频部分并将其另存为 mp4 文件
        $outputStream = [System.IO.File]::Create($newVideoFile)
        $buffer = New-Object byte[] 4096
        while (($bytesRead = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $outputStream.Write($buffer, 0, $bytesRead)
        }

        # 关闭输入和输出流
        $inputStream.Close()
        $outputStream.Close()

        Write-Host "提取视频部分并将其另存为 $newVideoFile"
    } catch {
        Write-Host "处理文件时出错： $_"
        return
    }
}

# 遍历目录并处理 MVIMG 文件的函数
function Traverse-Directory {
    param (
        [string]$dir
    )

    # 查找所有 MVIMG*.jpg 文件并进行处理
    Get-ChildItem -Path $dir -Filter "MVIMG*.jpg" -Recurse | ForEach-Object {
        Process-MVIMG $_.FullName
    }
}

# 处理输入路径的主逻辑
if (Test-Path $inputPath) {
    if ((Get-Item $inputPath).PSIsContainer) {
        # 如果它是一个目录，则遍历它
        Traverse-Directory $inputPath
    } elseif ($inputPath -like "MVIMG*.jpg") {
        # 如果是匹配模式的文件，则对其进行处理
        Process-MVIMG $inputPath
    } else {
        Write-Host "文件 $inputPath 与 MVIMG*.jpg 格式不匹配，无法处理"
    }
} else {
    Write-Host "请提供有效的文件或目录路径"
}
