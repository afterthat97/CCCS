# 服务端代码说明

## signin.php

管理用户登录。需要参数：

* `username`：用户名
* `password`：密码
* `type`：类型（`Teacher` 或者 `Student`）

如果成功匹配，返回 `code` 为 0，且会返回该用户的详细信息；否则 `code` 为 1，且会返回错误信息。

### 示例请求

```
signin.php?username=stu1&password=liudashi666&type=Student
```

### 示例答复

成功：

```
{  
  "code":0,
  "info":{  
    "sid":"1",
    "username":"s1",
    "password":"p1",
    "realname":"Alfred",
    "gender":"Male"
  }
}
```

失败：

```
{  
  "code":1,
  "info":"Wrong username or password."
}
```

## signup.php

管理新用户注册。需要参数：

* `username`：用户名
* `password`：密码
* `realname`：真实姓名
* `type`：类型（`Teacher` 或者 `Student`）
* `gender`：性别（`Male` 或者 `Female`）

如果成功注册，返回 `code` 为 0；否则 `code` 为 1，且会返回错误信息。

### 示例请求

```
signup.php?username=t2&passsword=p2&type=Teacher&gender=Male&realname=Eric
```

### 示例答复

成功：

```
{  
  "code":0,
  "info":"You have registered succussfully!"
}
```

失败：

```
{  
  "code":1,
  "info":"Registration failed: username already exists."
}
```

## getCourseList.php

获取课表信息。需要参数：

* `username`：用户名
* `password`：密码
* `type`：类型（`Teacher` 或者 `Student`）
* `all`：可选参数

如果 `all=1`，将返回数据库中的整个课程列表；否则将按照类型：对于老师将返回其所教授的课程列表，对于学生将返回其所选中的所有课程列表。

### 示例请求

```
getCourseList.php?username=s1&password=p1&type=Student
```

### 示例答复

**注意**：每个课程（`Course`）可以拥有一个或多个课堂（`Lesson`）。每个 `Lesson` 对应一次上课记录，如果 `lessonlist` 为空，则表示该课程到目前还没有上过课。

```
{  
  "code":0,
  "info":[  
    {  
      "cid":"1",
      "name":"Python",
      "credit":"3",
      "teacher":{  
        "tid":"1",
        "username":"t1",
        "realname":"Dr.Liu",
        "gender":"Male"
      },
      "lessonlist":[  
        {  
          "lid":"1",
          "cid":"1",
          "start_time":"2018-11-04 10:08:50",
          "end_time":null,
          "latitude":"34.24510560487807",
          "longitude":"108.9822649883938"
        }
      ]
    },
    {  
      "cid":"2",
      "name":"Java",
      "credit":"3",
      "teacher":{  
        "tid":"2",
        "username":"t2",
        "realname":"Prof.Zhao",
        "gender":"Female"
      },
      "lessonlist":[  

      ]
    }
  ]
}
```