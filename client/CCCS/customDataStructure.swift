//
//  customDataStructure.swift
//  CCCS
//
//  Created by Alfred Liu on 11/1/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import Foundation

let serverDir = "http://47.95.238.186/cccs"

var user = User("", [:])

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

class Course {
    var cid: Int
    var teacher: Teacher
    var name: String
    var credit: Int
    var place: String
    var lessonlist: [Lesson]
    init(_ dic: [String : Any]) {
        self.cid = Int(dic["cid"] as? String ?? "-1")!
        self.teacher = Teacher(dic["teacher"] as? [String : Any] ?? [:])
        self.name = dic["name"] as? String ?? ""
        self.credit = Int(dic["credit"] as? String ?? "-1")!
        self.place = dic["place"] as? String ?? ""
        self.lessonlist = []
        for lessonDic in dic["lessonlist"] as? [[String : Any]] ?? [[:]] {
            self.lessonlist.append(Lesson(lessonDic))
        }
    }
}

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
