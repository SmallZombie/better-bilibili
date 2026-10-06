# better_bilibili
Better than better

## 关于 media-kit-windows 下载失败
```
1. 下载 `https://sourceforge.net/projects/mdk-sdk/files/nightly/mdk-sdk-windows-x64.7z/download`
2. 将 `mdk-sdk-windows-x64.7z` 解压到 `D:\Project\Code\better-bilibili\windows\flutter\ephemeral\.plugin_symlinks\fvp\windows\`
解压完成后，目录结构大致会是：
... \fvp\windows\mdk-sdk\lib\cmake\FindMDK.cmake 等文件
```


## 如何编译 proto
```
dart pub global activate protoc_plugin
protoc --dart_out=lib/data/model/bilibili -I assets assets/bilibili.proto --plugin=protoc-gen-dart="$env:LOCALAPPDATA\Pub\Cache\bin\protoc-gen-dart.bat"
```


## 关于项目中的一些命名
- 追番叫做订阅剧集
- 追剧叫做订阅电影
- 追漫叫做订阅漫画
- 收藏收藏夹叫做订阅收藏夹
- 个人认证叫 isVerified
- 企业认证叫 isEnterpriseVerified
- 原始粉丝叫早期粉丝(earlyFan)

- 关注还是关注(follow)
- 订阅合集还是订阅合集


## 文档
- MPV: https://mpv.io/manual/master/
- TTML: https://amll.dev/guides/lyric/ttml
- AMLL DB: https://amlldb.bikonoo.com/
- LRC File: https://en.wikipedia.org/wiki/LRC_(file_format)
- File/Path picker: https://github.com/miguelpruivo/flutter_file_picker/wiki
- L10n: https://docs.flutter.dev/ui/internationalization
- MediaSession: https://github.com/wyrindev/flutter-media-session/blob/main/doc/usage.md
- BSBSB: https://github.com/hanydd/BilibiliSponsorBlock/wiki/API


## 自定义图标
- Package name: CustomIcons
- https://www.fluttericon.com/
- 放入 /raw 里的全部 svg

### 无痕模式图标 (incognito)
- https://pictogrammers.com/library/mdi/icon/incognito/
- https://pictogrammers.com/library/mdi/icon/incognito-circle/
- https://pictogrammers.com/library/mdi/icon/incognito-circle-off/
- https://pictogrammers.com/library/mdi/icon/incognito-off/


## 有关性能优化
- https://github.com/awesome-tips/Flutter-Tips/blob/master/articles/Flutter%20%20%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96%E2%80%94%E2%80%94%E5%A6%82%E4%BD%95%E9%81%BF%E5%85%8D%E5%BA%94%E7%94%A8%20jank.md


## 关于路由
目前 Better 使用 GoRouter 作为路由系统，未来也许会迁移到其他更强大又方便的路由系统，下面列出候选者：

- Beamer: https://pub.dev/packages/beamer
非常强大，但也非常复杂，学习/迁移成本过高，但他能胜任非常复杂的场景(存疑，毕竟我没学会)，如果学习/迁移成本不高的话 Better 现在应该已经用上这个包了

- AutoRoute: https://pub.dev/packages/auto_route
支持原生处理 DeepLink，支持自动扫描并生成路由，支持 TabRoute，还有更好的路由守卫、观察者等等功能(相比 GoRouter)，如果要我选一个替代现在的 GoRouter，AutoRoute 绝对是首选
补充: 状态恢复貌似不太行(相比之下 GoRouter 支持完整的状态恢复): https://www.reddit.com/r/FlutterDev/comments/17bjopv/comment/k5o5eno/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

## 自定义图标
### v1
- 彗星: https://icon.kitchen/i/H4sIAAAAAAAAA0VRzW6DMAx-F--KplJEt3Hb1nanSZO2W1VNgSQQKSQsP1srxLvPDqXlAM7H92M7I_wyHYWHagTZvlptHVRwV8gyr0vIoL5hMj2IIU-rgblAIi_wA1xIFnXAn6qxBoHeBmXNd62jg4lsvsQpRCdQMh_PA9bQJHMC3hzjSpjZM9ghdbSi3LLYbPc7JOV02jwX290jeTLTavQo8jI5vgvfkWawygRUH0Y4QbW6X5cZnJdizruZTtmF9bCwqLiylrAjJoRO9IJDJZn2gpbwwThXpqVM7BeqfJ2BU22HI1BZ2xBsP9dayISmRj87lmb3P1G5BkfIYPAv6INrz_P6aZ2AfQIuO0ddb3nUdE8HHJw7qzgt23p8_4kajtM_k-v1cMoBAAA

### v2
- 枫叶: https://icon.kitchen/i/H4sIAAAAAAAAA0VRwW7CMAz9F-9aTZSqjPW2Ddhp0qTthjikidNGCkmXpAOE-PfZ6YAe2pfX5_ds5wy_wo4YoTmD7t689QEaeND5gQLaOyfbWoolcaSzZhAhcVFE-oBCLUab6KeR3hEhhXOiNREu7PGNxzQGJP10PA2EQWZnJt6DUAbdZJj8kNuZcWhdLVabNYlKPi1eqtV6yZ7CdZY8qrLOjh8Ye64ZvHGJqrdnOEIze5zXBZyuYMq7m16Kf9XTVcXgprqG7Sgh9bhHBU0KI_ICPoVSxnUcSe1CU84LCKbraQKGrU_J7ydsUWc29_nVizx6_BlNkDRBAUN8JR94qMqyfZ5nYpOJ2x3obq01Sp4LYi-UP_AG9l6Nli9uS8tQwRvF2_eR3gdsYXf5Az-bQanbAQAA

### launcher_icons
旧包 [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) 目前已经停更一年，better 在尝试解决 windows 图标只生成一个尺寸版本的问题时找到了，[launcher_icons](https://pub.dev/packages/launcher_icons)，他 fork 自旧包并增强了一些功能，正好解决了图标尺寸的问题

`dart run launcher_icons`


## 响度均衡之死
折腾了一天最后发现 media_kit 自带的 mpv 不支持 AudioFilter，自己编译和替换时间成本太高了，已经写好的部分就先注释掉留着了，以后再说吧


## 有关存储
- best-local-database-for-flutter-apps-a-complete-guide#heading-when-not-to-use-a-local-database: https://github.com/isar/hive/issues/1331#issuecomment-3340563813
