//
//  courseTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/30/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class courseTableViewController: UITableViewController {
    @IBOutlet weak var courseTableView: UITableView!
    var courseList = [Course]()
    var selectedCourse: Course = Course([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeGetCourseListCall()
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
    
    @IBAction func refreshCourseList(_ sender: Any) {
        makeGetCourseListCall()
    }
    
    @IBAction func addOrSelectCourse(_ sender: Any) {
        if (user.type == "Teacher") {
            self.performSegue(withIdentifier: "segueToAddCourse", sender: self)
        } else {
            self.performSegue(withIdentifier: "segueToSelectCourse", sender: self)
        }
    }
    
    func makeGetCourseListCall() {
        let str = "\(serverDir)/getCourseList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)"
        let urlRequest = URLRequest(url: URL(string: str)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Response Error.")
                return
            }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                let responseDic = responseJson as! [String : Any]
                if (responseDic["code"] as! Int == 1) {
                    self.showAlert("Error", responseDic["info"] as! String)
                } else {
                    self.courseList.removeAll()
                    for courseDic in responseDic["info"] as! [[String : Any]] {
                        self.courseList.append(Course(courseDic))
                    }
                    DispatchQueue.main.async { self.courseTableView.reloadData() }
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return courseList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courseList[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Course:"
            cell.detailTextLabel?.text = self.courseList[indexPath.section].name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = self.courseList[indexPath.section].teacher.realname
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Place:"
            cell.detailTextLabel?.text = self.courseList[indexPath.section].place
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Status:"
            if (self.courseList[indexPath.section].lessonlist.count == 0 ||
                self.courseList[indexPath.section].lessonlist[0].end_time != "") {
                cell.detailTextLabel?.text = "Not Started"
            } else {
                cell.detailTextLabel?.text = "Started"
            }
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 3) {
            selectedCourse = self.courseList[indexPath.section]
            self.performSegue(withIdentifier: "segueToCourseDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is courseDetailViewController {
            let t = segue.destination as? courseDetailViewController
            t?.selectedCourse = self.selectedCourse
        }
    }
}
