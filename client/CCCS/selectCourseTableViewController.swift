//
//  selectCourseTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/3/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class selectCourseTableViewController: UITableViewController {
    @IBOutlet var courseTableView: UITableView!
    var courseListAll = [Course]()
    
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
    
    func makeGetCourseListCall() {
        let str = "\(serverDir)/getCourseList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&all=1"
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
                    self.courseListAll.removeAll()
                    for courseDic in responseDic["info"] as! [[String : Any]] {
                        self.courseListAll.append(Course(courseDic))
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
    
    func makeSelectCourseCall(_ cid : Int) {
        let url = URL(string: "\(serverDir)/selectCourse.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(cid)")
        let urlRequest = URLRequest(url: url!)
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
                    self.showAlert("Success", responseDic["info"] as! String)
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return self.courseListAll.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.courseListAll[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        cell.selectionStyle = .none
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Course:"
            cell.detailTextLabel?.text = self.courseListAll[indexPath.section].name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = self.courseListAll[indexPath.section].teacher.realname
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Credit:"
            cell.detailTextLabel?.text = String(self.courseListAll[indexPath.section].credit)
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Select"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 3) {
            makeSelectCourseCall(self.courseListAll[indexPath.section].cid)
        }
    }
}
