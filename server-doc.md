## setup.php

建立、配置 MYSQL 数据库。请先自行安装好 MySQL 数据库并**将用户、密码填入 `config.php` 中**。本脚本不需要请求参数，直接在浏览器中访问即可。

### 示例答复

```
Successfully connected to MySQL.

Create new database 'cccs'...

Successfully connected to database 'cccs'.

Checking tables....

Table 'Student' created successfully.

Table 'Teacher' created successfully.

Table 'Course' created successfully.

Table 'Lesson' created successfully.

Table 'StudentCourse' created successfully.

Table 'StudentLesson' created successfully.

Everything works fine.
```

## config.php

主要包含：

* `$dbhost`, `$dbuser`, `$dbpass`, `$dbname`：数据库交互时候所需的账户和密码等信息
* `$checkin_distance_limit`：签到的距离限制（单位：米）
* `$checkin_time_limit`：签到的时间限制（单位：秒）
* `$answer_question_time_limit`：回答问题的时间限制（单位：秒）

## signin.php

管理用户登录。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型（`Teacher` 或者 `Student`）

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
* `type`：用户类型（`Teacher` 或者 `Student`）
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

## addCourse.php

只有用户为老师时生效，用来添加新的课程。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型（`Teacher` 或者 `Student`）
* `name`：课程名
* `credit`：课程学分
* `place`：课程地点

### 示例请求

```
addCourse.php?username=t1&password=p1&type=Teacher&name=python&credit=2&place=a202
```

### 示例答复

成功：

```
{
   "code":0,
   "info":"Course has been added."
}
```

失败：

```
{  
   "code":1,
   "info":"Course already exists."
}
```

## selectCourse.php

只有用户为学生时生效，选择想要上的课程。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `cid`：课程编号


### 示例请求

```
selectCourse.php?username=s1&password=p1&type=Student&cid=2
```

### 示例答复

成功：

```
{
   "code":0,
   "info":"Course has been selected."
}
```

失败：

```
{  
   "code":1,
   "info":"You have already selected it."
}
```

## getCourseList.php

获取课表信息。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型（`Teacher` 或者 `Student`）
* `all`：可选参数

如果 `all=1`，将返回数据库中的整个课程列表；否则将按照类型：对于老师将返回其所教授的课程列表，对于学生将返回其所选中的所有课程列表。

### 示例请求

```
getCourseList.php?username=s1&password=p1&type=Student
```

### 示例答复

每个课程（`Course`）可以拥有一个或多个课堂（`Lesson`）。每个 `Lesson` 对应一次上课记录，如果 `lessonlist` 为空，则表示该课程到目前还没有上过课。

对于某个课堂（`Lesson`）而言，其 `"end_time":null` 表示该课堂还没有结束（上课中），这种情况只会在最近的一次课堂中出现。

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

## getLessonList.php

获取一门课程下多个课堂的地理位置信息和时间信息。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型（`Teacher` 或者 `Student`）
* `cid`：当前课程编号

### 示例请求

```
getLessonList.php?username=t1&password=p1&type=Teacher&cid=4
```

### 示例答复

对于某个课堂（`Lesson`）而言，其 `"end_time":null` 表示该课堂还没有结束（上课中），这种情况只会在最近的一次课堂中出现。

```
{
   "code":0,
   "info":[
      {
         "lid":"8",
         "cid":"4",
         "start_time":"2018-12-21 20:58:35",
         "end_time":null,
         "latitude":"37.785834",
         "longitude":"-122.406417"
      },
      {
         "lid":"7",
         "cid":"4",
         "start_time":"2018-12-21 17:03:08",
         "end_time":"2018-12-21 19:58:13",
         "latitude":"37.785834",
         "longitude":"-122.406417"
      },
      {
         "lid":"6",
         "cid":"4",
         "start_time":"2018-12-21 10:42:33",
         "end_time":"2018-12-21 10:52:49",
         "latitude":"37.785834",
         "longitude":"-122.406417"
      }
   ]
}
```


## startLesson.php

老师开始上课，服务器记录老师上课的位置信息。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `cid`：当前课程编号
* `latitude`：纬度信息
* `longitude`：经度信息

### 示例请求

```
startLesson.php?username=t1&password=p1&type=Teacher&cid=4&latitude=37.785834&longitude=-122.406417
```

### 示例答复

```
{
   "code":0,
   "info":"New lesson starts."
}
```

## stopLesson.php

老师下课。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `cid`：当前课程编号

### 示例请求

```
stopLesson.php?username=t1&password=p1&type=Teacher&cid=4
```

### 示例答复

```
{
   "code":0,
   "info":"Lesson is over, 0 student(s) absent, 0 student(s) leaving early."
}
```

## checkin.php

学生签到请求。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `cid`：当前课程编号
* `latitude`：纬度信息
* `longitude`：经度信息

### 示例请求

```
checkin.php?username=s1&password=p1&type=Student&cid=4&latitude=37.785834&longitude=-122.406417
```

### 示例答复

成功——正常签到：

```
{
   "code":0,
   "info":"Welcome to class!"
}
```

成功——但迟到：

```
{
   "code":0,
   "info":"Welcome to class! But you are late."
}
```

失败——超出考勤的距离限制：

```
{  
   "code":1,
   "info":"You are too far away.(198m)"
}
```

失败——已经考勤过：

```
{  
   "code":1,
   "info":"You have checked in at 2018-12-22 10:05:10."
}
```

失败——课程尚未开始：

```
{  
   "code":1,
   "info":"Lesson not started."
}
```

## getAttendance.php

获取出勤信息。需要参数：

* `username`：用户名
* `password`：密码
* `type` ：用户类型（`Teacher` 或者 `Student`）
* `cid` ：当前课程编号

如果用户是老师，那么将返回所有选了这门课的学生的考勤情况；否则只返回学生本人在这门课的考勤情况。

### 示例请求

```
getAttendance.php?username=t1&password=p1&type=Teacher&cid=4
```

### 示例答复

```
{
   "code":0,
   "info":[
      {
         "checkin_time":"2018-12-21 11:04:22",
         "status":"Normal",
         "student":{
            "sid":"1",
            "username":"s1",
            "realname":"liudashi",
            "gender":"Male"
         },
         "lesson":{
            "lid":"7",
            "cid":"4",
            "start_time":"2018-12-21 11:03:08",
            "end_time":"2018-12-21 19:58:13",
            "latitude":"37.785834",
            "longitude":"-122.406417"
         }
      },
      {
         "checkin_time":"2018-12-22 10:05:10",
         "status":"Leave Early",
         "student":{
            "sid":"1",
            "username":"s1",
            "realname":"liudashi",
            "gender":"Male"
         },
         "lesson":{
            "lid":"10",
            "cid":"4",
            "start_time":"2018-12-22 10:04:45",
            "end_time":"2018-12-24 09:03:33",
            "latitude":"37.785834",
            "longitude":"-122.406417"
         }
      }
   ]
}
```

## raiseQuestion.php

老师提问，且只能在上课时进行提问。需要参数：

* `username`：用户名
* `password`：密码
* `type` ：用户类型
* `lid` ：当前课堂编号
* `description` ：问题描述 
* `option$x` ：第x个选项的描述 (最多四个选项)
* `answer` ：问题答案 

### 示例请求

```
raiseQuestion.php?username=t1&password=p1&type=Teacher&lid=10&description=Python3%E2%80%99s%20package%20manager?&answer=2&option0=apt-get&option1=pip&option2=pip3&option3=yum
```

### 示例答复

```
{
   "code":0,
   "info":"Question raised."
}
```

## getQuestionList.php

获取对应课程已经提过的问题列表。需要参数：

* `username`：用户名
* `password`：密码
* `type` ：用户类型
* `cid` ：当前课程编号

### 示例请求

```
getQuestionList.php?username=t1&password=p1&type=Teacher&cid=4
```

### 示例答复

```
{
   "code":0,
   "info":[
      {
         "qid":"4",
         "lid":"7",
         "description":"When was Python invented?",
         "raised_time":"2018-12-21 11:03:57",
         "option0":"1979",
         "option1":"1989",
         "option2":"1999",
         "option3":"",
         "answer":"1"
      },
      {
         "qid":"6",
         "lid":"10",
         "description":"Python3\u2019s package manager?",
         "raised_time":"2018-12-22 10:54:54",
         "option0":"apt-get",
         "option1":"pip",
         "option2":"pip3",
         "option3":"yum",
         "answer":"2"
      }
   ]
}
```

## answerQuestion.php

学生回答课堂上的提问。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `qid`：问题编号
* `choice` ：所选问题选项
* `latitude`：纬度信息
* `longitude`：经度信息

### 示例请求

```
answerQuestion.php?username=s1&password=p1&type=Student&qid=5&choice=0&latitude=37.785834&longitude=-122.406417
```

### 示例答复

成功：

```
{
   "code":0,
   "info":"Submitted successfully."
}
```

失败——已经回答过该问题：

```
{  
   "code":1,
   "info":"You have answered at 2018-12-22 10:26:09"
}
```

失败——回答问题时候超出离老师的距离限制：

```
{  
   "code":1,
   "info":"You are too far away. (192 m)"
}
```

## getAnswerList.php

老师获取某道题的学生答题情况。需要参数：

* `username`：用户名
* `password`：密码
* `type`：用户类型
* `qid`：问题编号

### 示例请求

```
getAnswerList.php?username=t1&password=p1&type=Teacher&qid=5
```

### 示例答复

```
{
   "code":0,
   "info":[
      {
         "submit_time":"2018-12-22 10:26:09",
         "choice":"2",
         "student":{
            "sid":"1",
            "username":"s1",
            "realname":"liudashi",
            "gender":"Male"
         },
         "question":{
            "qid":"6",
         	  "lid":"10",
            "description":"Python3\u2019s package manager?",
            "raised_time":"2018-12-22 10:54:54",
            "option0":"apt-get",
            "option1":"pip",
            "option2":"pip3",
            "option3":"yum",
            "answer":"2"
         }
      }
   ]
}

```

## testConnection.php

用于测试客户端和服务器的通信是否正常，在 APP 启动时请求。
