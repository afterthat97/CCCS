//
//  attendanceTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/3/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class attendanceTableViewController: UITableViewController {
    @IBOutlet var attendanceTableView: UITableView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var selectedCourse: Course = Course([:])
    var currentLessonLid: Int = -1
    var checkinRecordsAll = [CheckinRecord]()
    var checkinRecordsCnt = [CheckinRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (selectedCourse.lessonlist.count != 0 &&
            selectedCourse.lessonlist[0].end_time == "") {
            currentLessonLid = selectedCourse.lessonlist[0].lid
        }
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshData),for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "Loading")
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func refreshData(){
        refreshControl!.beginRefreshing()
        makeGetAttendanceCall()
    }
    
    @IBAction func filterValueChanged(_ sender: Any) {
        attendanceTableView.reloadData()
    }
    
    func makeGetAttendanceCall() {
        let str = "\(serverDir)/getAttendance.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(selectedCourse.cid)"
        let urlRequest = URLRequest(url: URL(string: str)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Response Error.")
                return
            }
            DispatchQueue.main.async {
                self.refreshControl!.endRefreshing()
            }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                let responseDic = responseJson as! [String : Any]
                if (responseDic["code"] as! Int == 1) {
                    self.showAlert("Error", responseDic["info"] as! String)
                } else {
                    self.checkinRecordsAll.removeAll()
                    self.checkinRecordsCnt.removeAll()
                    for checkinRecordDic in responseDic["info"] as! [[String : Any]] {
                        let checkinRecord = CheckinRecord(checkinRecordDic)
                        self.checkinRecordsAll.append(checkinRecord)
                        if (checkinRecord.lesson.lid == self.currentLessonLid) {
                            self.checkinRecordsCnt.append(checkinRecord)
                        }
                    }
                    DispatchQueue.main.async {
                        self.attendanceTableView.reloadData()
                    }
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (filterSegmentedControl.selectedSegmentIndex == 0) {
            return checkinRecordsCnt.count
        } else {
            return checkinRecordsAll.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Record \(section + 1)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        if (filterSegmentedControl.selectedSegmentIndex == 0) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Student:"
                cell.detailTextLabel?.text = self.checkinRecordsCnt[indexPath.section].student.realname
            } else if (indexPath.row == 1) {
                cell.textLabel?.text = "Start time:"
                cell.detailTextLabel?.text = self.checkinRecordsCnt[indexPath.section].lesson.start_time
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "Checkin time:"
                cell.detailTextLabel?.text = self.checkinRecordsCnt[indexPath.section].checkin_time
            } else {
                cell.textLabel?.text = "Status:"
                cell.detailTextLabel?.text = self.checkinRecordsCnt[indexPath.section].status
            }
        } else {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Student:"
                cell.detailTextLabel?.text = self.checkinRecordsAll[indexPath.section].student.realname
            } else if (indexPath.row == 1) {
                cell.textLabel?.text = "Start time:"
                cell.detailTextLabel?.text = self.checkinRecordsAll[indexPath.section].lesson.start_time
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "Checkin time:"
                cell.detailTextLabel?.text = self.checkinRecordsAll[indexPath.section].checkin_time
            } else {
                cell.textLabel?.text = "Status:"
                cell.detailTextLabel?.text = self.checkinRecordsAll[indexPath.section].status
            }
        }
        return cell
    }
}
