# Naptime File Protocol Library

Naptime [文件协议](https://github.com/EnterTech/Documents/blob/master/%E7%89%88%E6%9C%AC%E8%A7%84%E8%8C%83/Data-File-Protocol.md) 的实现库

## Installation

```ruby
# 指定 pod 仓库源
source 'git@github.com:EnterTech/PodSpecs.git'

# 指定 pod 库及版本
pod 'NaptimeFileProtocol', '~> 0.1.0'
```

运行 Pod 安装命令

```shell
pod install
```

## Usage
### 原始脑波数据文件
主要提供 2 个基本协议实现类

- BrainWaveFileReader

    ```swift
    // 加载文件
    let brainWaveFileReader = BrainWaveFileReader()
    brainWaveFileReader.loadFile(fileURL)
    // 然后可以直接拿到所有协议相关数据，和完整的原始脑波数据序列 [BrainWaveData]
    ```

- BrainWaveFileWriter

    ```swift
    // 创建文件
    let brainWaveFileWriter = BrainWaveFileWriter()
    brainWaveFileWriter.createFile(fileURL)
    // 然后写入数据
    let brainWave = BrainWaveData(value: 888)
    brainWaveFileWriter.writeBrainWave(brainWave)
    // 或者写入整段数据
    // let brainData = NSData(xxx)
    brainWaveFileWriter.writeData(brainData)
    // 关闭文件
    brainWaveFileWriter.close()
    ```

### 分析后数据文件

- AnalyzedFileReader

    ```swift
    // 加载文件
    let analyzedFileReader = AnalyzedFileReader()
    analyzedFileReader.loadFile(fileURL)
    // 然后可以直接拿到所有协议相关数据，和完整的分析后数据序列 [AnalyzingData]
    ```

- AnalyzedFileWriter

    ```swift
    // 创建文件
    let analyzedFileWriter = AnalyzedFileWriter()
    analyzedFileWriter.createFile(fileURL)
    // 然后写入数据
    let analyzingData = AnalyzingData(dataQuality: 0, soundControl: 0, awakeStatus: 0, sleepStatusMove: 80, restStatusMove: 73, wearStatus: 0)
    analyzedFileWriter.writeAnalyzingData(analyzingData)
    // 或者写入整段数据
    // let analyzingData = NSData(xxx)
    analyzedFileWriter.writeData(analyzingData)
    // 关闭文件
    analyzedFileWriter.close()
    ```

## License
内部使用，不得公开。


