//
//  courseTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/30/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class Course {
    var id : Int = 0
    var name : String = ""
    var credit : Int = 0
    var place : String = ""
    var teacher : String = ""
    var started : Bool = false
    var start_time : String = "N/A"
}

var courses = [Course]()

class courseTableViewController: UITableViewController {
 
    @IBOutlet weak var courseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeGetCourseCall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func makeGetCourseCall() {
        var loadedCourses = [Course]()
        var todoEndpoint: String = "https://breeze.xin/getCourse.php"
        if (user.type == "Student") {
            todoEndpoint = todoEndpoint + "?sid=\(user.id)"
        } else {
            todoEndpoint = todoEndpoint + "?tid=\(user.id)"
        }
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else { return }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String : Any]];
                
                for object in todo! {
                    let course : Course = Course()
                    course.id = Int((object["cid"] as? String)!)!
                    course.name = (object["name"] as? String)!
                    course.place = (object["place"] as? String)!
                    course.credit = Int((object["credit"] as? String)!)!
                    course.teacher = (object["teacher"] as? String)!
                    course.started = Int((object["started"] as? String)!)! == 1 ? true : false
                    if (course.started) {
                        course.start_time = object["start_time"] as? String ?? "N/A"
                    }
                    loadedCourses.append(course)
                }
                
                courses = loadedCourses
                
                DispatchQueue.main.async { [unowned self] in
                    self.courseTableView.reloadData()
                }
            } catch { return }
        }
        
        task.resume()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section < courses.count) {
            return courses[section].name
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if (indexPath.section >= courses.count) { return cell }
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = courses[indexPath.section].teacher
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Place:"
            cell.detailTextLabel?.text = courses[indexPath.section].place
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Status:"
            cell.detailTextLabel?.text = courses[indexPath.section].started ? "Started" : "Not Started"
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            selectedCourse = indexPath.section
            self.performSegue(withIdentifier: "segueToCourseDetail", sender: self)
        }
    }
}
