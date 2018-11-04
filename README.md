基于指纹识别与 GPS 定位的课堂考勤系统。

## 硬件要求

* 一台拥有 HTTP + PHP + MySQL 运行环境的服务器
* 一台拥有指纹和 GPS 功能的 iPhone 手机（iOS 12+）。

## 配置服务器

1. 将所有的 PHP 代码放到服务器的 Web 目录下（例如 `http://domain.com/cccs/`），保证外界可以正常访问
2. 配置 MySQL 数据库，将用户密码写入 `config.php` 中
3. 在浏览器中直接访问 `http://domain.com/cccs/setup.php` 完成数据库建库（详见服务器 API 文档）
4. 在 iOS 客户端代码 `customDataStructure.swift` 中找到 `serverDir` 变量，并填入服务端目录地址
5. 使用 Xcode 编译客户端即可

## 文档

服务端 API 文档：[doc/server_doc.md](doc/server_doc.md)

客户端 API 文档：[doc/client_doc.md](doc/client_doc.md)

## 鸣谢

breeze