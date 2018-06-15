# MOD 开发在 tatfook/keepwork 仓库的 lessons 分支下
https://github.com/tatfook/keepwork/tree/lessons

### 未完成：
- 所有 MOD 的前台页面的多语言

# 服务端（npl 环境）
https://github.com/caoyongfeng0214/lesson
### 未完成：
- 激活码管理 - 后台管理的前端

# lesson 项目部署过程
1. clone仓库到本地（https://github.com/caoyongfeng0214/lesson.git）
2. 修改配置项：
> /config/dbConfi.lua 修改数据库配置
    /config/siteConfig.lua 修改对应环境的 keepwork 的 HOST 以及 ES 的 api 地址
    /public/js/common.js 修改对应环境的 keepwork 的 HOST -> keepworkHost
    /app.js 添加 res.__data__.baseUrl 来配置 `lesson` 需要放置的域
3. 执行 sql 脚本
> /sql/db.sql 创建数据库与表结构
4. 将 /luasql.so （Linux 下）文件放在 `lesson` 项目根目录下 
> 注： Linux 下编译 `NPLRuntime` 之前需要安装 `mysql` 程序才有作用
5.  在根目录下运行 npl -d bin/www.npl 
