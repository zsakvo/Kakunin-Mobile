<h3 align="center">踟蹰 - MD3 风格的二步验证工具</h3>
<p align="center">  
请注意，项目尚在开发中。如果遇到任何问题和建议欢迎在 issues 中讨论
</p>
<br/>
<p align="center">  <img width="240" src="https://user-images.githubusercontent.com/25399519/221909358-bf6faac0-f7bb-4943-9ead-13d424bec9e8.png" title="Main Screenshot">
<img width="240" src="https://user-images.githubusercontent.com/25399519/222937733-96736a21-fe4e-43a9-ae2b-55bdc3f33b5b.png"  >
<img width="240" src="https://user-images.githubusercontent.com/25399519/222937731-6866a857-0e32-495a-81d9-51d3b6d552db.png"  > 
</p>
</a>
<br/>
 
## 免责声明
- ⚠️ 本项目正在 **随缘** 的开发中。
- ⚠️ 可能存在 bug 或者重大变更。
- ⚠️ **暂时不要把本软件作为你验证的唯一工具!**

## 特性

### 2023.03.05

- 支持扫描来自 Google 身份验证器的二维码
- 支持数据导出到本地 （明文）
- 支持数据备份到 Google 云端硬盘（RSA 加密）`相关密钥在 https://github.com/zsakvo/Kakunin-Mobile/blob/main/lib/utils/encode.dart 内`
- 支持启动时的安全认证

### init ver.

- 支持 TOTP 以及 HOTP
- 支持手动输入参数，扫码，解析 `otpauth://` 三种导入方式
- 支持动态取色

## 待开发

- 云备份支持更多来源
- 导出数据为其它 APP 的兼容格式
- 导入更多来自其它程序的数据
- 完成 iOS 支持
