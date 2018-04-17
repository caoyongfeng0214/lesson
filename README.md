# lesson

https://github.com/caoyongfeng0214/lesson


## 使用说明

1.clone仓库到本地

2.为了进行npm包的安装，需要暂时移除`package.json`中关于npl的依赖说明（`dependencies`字段，请保存该部分内容，稍后恢复）：

```
// ...其他字段
// 移除该部分
"dependencies": {
  "express": "*",
  "lustache": "*",
  "cors": "*",
  "mysql": "*"
},
// ...其他字段
```

3.运行`npm install`

4.恢复`package.json`中移除的字段

5.安装`npl`运行时环境，请参考[NPLRuntime](https://github.com/LiXizhi/NPLRuntime)

6.初始化`mysql`数据库：根据`/sql`下的数据库文件初始化数据库

7.在`/confi/dbConfi.lua`下配置数据库链接参数

8.执行`gulp init`以及`gulp`即可在本地端口访问项目（默认3000端口）