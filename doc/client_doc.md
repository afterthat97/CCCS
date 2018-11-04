
## customDataStructure.swift

定义了考勤系统需要用到的数据结构。

### 用户

`user` 是一个全局变量，存储了当前登录用户的凭据。可以在任意 ViewController 中访问：

```
var user = User("", [:])
```

```
class User {
    var id: Int
    var username: String
    var password: String
    var realname: String
    var gender: String // Male or Female
    var type: String   // Student or Teacher
    init(_ type: String, _ dic: [String : Any]) {
        self.type = type
        if (type == "Student") {
            self.id = Int(dic["sid"] as? String ?? "-1")!
        } else {
            self.id = Int(dic["tid"] as? String ?? "-1")!
        }
        self.username = dic["username"] as? String ?? ""
        self.password = dic["password"] as? String ?? ""
        self.realname = dic["realname"] as? String ?? ""
        self.gender = dic["gender"] as? String ?? ""
    }
}
```

### 学生

定义学生数据结构：

```
class Student {
    var sid : Int
    var username : String
    var realname : String
    var gender : String
    init(_ dic: [String : Any]) {
        self.sid = Int(dic["sid"] as? String ?? "-1")!
        self.username = dic["username"] as? String ?? ""
        self.realname = dic["realname"] as? String ?? ""
        self.gender = dic["gender"] as? String ?? ""
    }
}
```

### 教师

定义教师数据结构：

```
class Teacher {
    var tid : Int
    var username : String
    var realname : String
    var gender : String
    init(_ dic: [String : Any]) {
        self.tid = Int(dic["tid"] as? String ?? "-1")!
        self.username = dic["username"] as? String ?? ""
        self.realname = dic["realname"] as? String ?? ""
        self.gender = dic["gender"] as? String ?? ""
    }
}
```

### 课程

每个课程（`Course`）有且仅有一个教师（`Teacher`），有一个或多个课堂（`Lesson`）。每个 `Lesson` 对应一次上课记录，如果 `lessonlist` 为空，则表示该课程到目前还没有上过课。

```
class Course {
    var cid: Int
    var teacher: Teacher
    var name: String
    var credit: Int
    var lessonlist: [Lesson]
    init(_ dic: [String : Any]) {
        self.cid = Int(dic["cid"] as? String ?? "-1")!
        self.teacher = Teacher(dic["teacher"] as? [String : Any] ?? [:])
        self.name = dic["name"] as? String ?? ""
        self.credit = Int(dic["credit"] as? String ?? "-1")!
        self.lessonlist = []
        for lessonDic in dic["lessonlist"] as? [[String : Any]] ?? [[:]] {
            self.lessonlist.append(Lesson(lessonDic))
        }
    }
}
```

### 课堂

表示一次上课记录，`cid` 表示其对应的课程（Course）ID。

```
class Lesson {
    var lid: Int
    var cid: Int
    var start_time: String
    var end_time: String
    init(_ dic: [String : Any]) {
        self.lid = Int(dic["lid"] as? String ?? "-1")!
        self.cid = Int(dic["cid"] as? String ?? "-1")!
        self.start_time = dic["start_time"] as? String ?? ""
        self.end_time = dic["end_time"] as? String ?? ""
    }
}
```

## 考勤

记录了某个学生（Student）在某次课堂（Lesson）的签到记录（包括签到时间和状态）。

状态包括三种：

* `Normal`：正常
* `Late`：迟到
* `Absent`：缺勤

```
class CheckinRecord {
    var student: Student
    var lesson: Lesson
    var checkin_time: String
    var status: String
    init(_ dic: [String : Any]) {
        self.student = Student(dic["student"] as? [String : Any] ?? [:])
        self.lesson = Lesson(dic["lesson"] as? [String : Any] ?? [:])
        self.checkin_time = dic["checkin_time"] as? String ?? ""
        self.status = dic["status"] as? String ?? ""
    }
}
```