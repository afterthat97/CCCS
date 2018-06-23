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
    var teacherName : String = ""
    var teacherGender : String = ""
    var started : Bool = false
    var start_time : String = ""
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

    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeGetCourseCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/course/getCourse.php?id=\(user.id)&type=\(user.type)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [[String : Any]]
                var loadedCourses = [Course]()
                for object in data {
                    let course : Course = Course()
                    course.id = Int(object["cid"] as! String)!
                    course.name = (object["name"] as! String)
                    course.place = (object["place"] as! String)
                    course.credit = Int(object["credit"] as! String)!
                    course.teacherName = (object["teacherName"] as! String)
                    course.teacherGender = (object["teacherGender"] as! String)
                    course.started = Int((object["started"] as! String))! == 1 ? true : false
                    if (course.started) {
                        course.start_time = (object["start_time"] as! String)
                    } else {
                        course.start_time = "N/A"
                    }
                    loadedCourses.append(course)
                }
                courses = loadedCourses
                DispatchQueue.main.async { [unowned self] in
                    self.courseTableView.reloadData()
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    @IBAction func refreshCourseList(_ sender: Any) {
        makeGetCourseCall()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courses[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if (indexPath.section >= courses.count) { return cell }
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.selectionStyle = .none
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = courses[indexPath.section].teacherName
        } else if (indexPath.row == 1) {
            cell.selectionStyle = .none
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
