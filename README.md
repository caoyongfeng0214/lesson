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

## 客户端接口说明

### 1.学生 Pad 进入教室

- **URL**

> [POST] /api/class/enter

- **参数**

| 请求参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| username  | String, 不可为空   | 用户名 |
| classId   | Number, 不可为空   | 房间ID，由教师给出 |
| studentNo | Number, 不可为空   | 学号 |

- **返回示例**

```
{
  "data": {
		"lessonUrl": "/keep/12211519639786370/ch/ch8?device=pad&classId=100547814&username=isyang&studentNo=0611011111"
	},
	"err": 0
}
```

- **返回说明**

| 返回参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| err| Number | 请求成功与否 0 成功; 200 房间不存在 |
| data| Object| lessonUrl 课程的 URL |
| message| String| 执行结果消息 |

- **其他说明**

当学生客户端输入由教师提供的 ClassID 进入，需要在客户端打开一个网页，该网页的网址为 data.lessonUrl

### 2.学生 Pad 更新自己的状态

- **URL**

> [POST] /api/class/upsertstate

- **参数**

| 请求参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| username  | String, 不可为空   | 用户名 |
| state   | Number, 不可为空   | 学习状态 1.learning 2.Leave learning page 3.Offline |

- **返回示例**

```
{
  "data": {
    "classId": "100547814",
    "username": "isyang"
  },
  "err": 0
}
```

- **返回说明**

| 返回参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| err| Number | 请求成功与否 0 成功; 201 课堂已结束; 202 用户不存在|
| data| Object| 当前用户信息 |
| message| String| 执行结果消息 |

- **其他说明**

由学生客户端调用该接口来维护学生在课堂上的状态


### 3.学生 PC 客户端更新学习状态

- **URL**

> [POST] /api/record/saveOrUpdate

- **参数**

| 请求参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| sn  | Number, 不可为空   | 自学的编号，该参数在 `PareCarf` 客户端打开的网页链接中获取 |
| state   | Number, 不可为空   | 自学的学习状态 1.自学中 2.自学结束 |

- **返回示例**

```
{
  "data": {
    "recordSn": "666"
  },
  "err": 0
}
```

- **返回说明**

| 返回参数 | 参数类型 | 参数说明 |
| :-------- | :--------| :------ |
| err| Number | 请求成功与否 0 成功; 101 db 操作错误|
| data| Object| recordSn 当前学习的编号 |
| message| String| 执行结果消息 |

- **其他说明**

由学生 `PareCarf` 客户端调用该接口来维护学生在课堂上的状态