//
//  courseDetailViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/3/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreLocation

class courseDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var courseDetailTableView: UITableView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var queryButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var cntLocation: CLLocation!
    var selectedCourse: Course = Course([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseDetailTableView.delegate = self
        courseDetailTableView.dataSource = self
        self.navigationItem.title = selectedCourse.name.removingPercentEncoding
        if (user.type == "Teacher") {
            mainButton.setTitle("Start/Stop Lesson", for: .normal)
            queryButton.setTitle("Query Attendance", for: .normal)
        } else {
            mainButton.setTitle("Check In", for: .normal)
            queryButton.setTitle("Query My Attendance", for: .normal)
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        cntLocation = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cntLocation = locations[locations.count - 1]
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeGetLessonListCall() {
        let str = "\(serverDir)/getLessonList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(selectedCourse.cid)"
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
                if (responseDic["code"] as! Int == 0) {
                    self.selectedCourse.lessonlist.removeAll()
                    for lessonDic in responseDic["info"] as! [[String : Any]] {
                        self.selectedCourse.lessonlist.append(Lesson(lessonDic))
                    }
                    DispatchQueue.main.async { self.courseDetailTableView.reloadData() }
                } else {
                    self.showAlert("Error", responseDic["info"] as! String)
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    func makeMainCall(_ urlString: String) {
        let urlRequest = URLRequest(url: URL(string: urlString)!)
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
                if (responseDic["code"] as! Int == 0) {
                    self.showAlert("Success", responseDic["info"] as! String)
                } else {
                    self.showAlert("Error", responseDic["info"] as! String)
                }
                self.makeGetLessonListCall()
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    @IBAction func mainEvent(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identification") {
                [unowned self] success, authenticationError in
                DispatchQueue.main.async {
                    if (success) {
                        if (user.type == "Teacher") {
                            if (self.selectedCourse.lessonlist.count == 0 ||
                                self.selectedCourse.lessonlist[0].end_time != "") {
                                self.makeMainCall("\(serverDir)/startLesson.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(self.selectedCourse.cid)&latitude=\(self.cntLocation.coordinate.latitude)&longitude=\(self.cntLocation.coordinate.longitude)")
                            } else {
                                self.makeMainCall("\(serverDir)/stopLesson.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(self.selectedCourse.cid)")
                            }
                        } else {
                            self.makeMainCall("\(serverDir)/checkin.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(self.selectedCourse.cid)&latitude=\(self.cntLocation.coordinate.latitude)&longitude=\(self.cntLocation.coordinate.longitude)")
                        }
                    }
                }
            }
        } else {
            self.showAlert("Touch ID not available", "Your device is not configured for Touch ID.")
        }
    }
    
    @IBAction func questionButtonTapped(_ sender: Any) {
        if (self.selectedCourse.lessonlist.count == 0 ||
            self.selectedCourse.lessonlist[0].end_time != "") {
            self.showAlert("Error", "Class not started.")
        } else {
            self.performSegue(withIdentifier: "segueToQuestionList", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Course:"
            cell.detailTextLabel?.text = self.selectedCourse.name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = self.selectedCourse.teacher.realname
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Credit:"
            cell.detailTextLabel?.text = String(self.selectedCourse.credit)
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Place:"
            cell.detailTextLabel?.text = self.selectedCourse.place
        } else if (indexPath.row == 4) {
            cell.textLabel?.text = "Status:"
            if (self.selectedCourse.lessonlist.count == 0 ||
                self.selectedCourse.lessonlist[0].end_time != "") {
                cell.detailTextLabel?.text = "Not Started"
            } else {
                cell.detailTextLabel?.text = "Started"
            }
        } else {
            cell.textLabel?.text = "Start time:"
            if (self.selectedCourse.lessonlist.count == 0 ||
                self.selectedCourse.lessonlist[0].end_time != "") {
                cell.detailTextLabel?.text = "N/A"
            } else {
                cell.detailTextLabel?.text = self.selectedCourse.lessonlist[0].start_time
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is attendanceTableViewController {
            let t = segue.destination as? attendanceTableViewController
            t?.selectedCourse = self.selectedCourse
        }
        if segue.destination is questionTableViewController {
            let t = segue.destination as? questionTableViewController
            t?.currentLesson = self.selectedCourse.lessonlist[0]
        }
    }
}
