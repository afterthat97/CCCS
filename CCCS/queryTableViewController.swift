//
//  queryTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/1/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class CheckinRecord {
    var name : String = ""
    var start_time : String = ""
    var checkin_time : String = ""
    var stat : String = ""
}

var checkinRecords = [CheckinRecord]()

class queryTableViewController: UITableViewController {

    @IBOutlet weak var checkinRecordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkinRecords.removeAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeGetCheckInRecordCall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func makeGetCheckInRecordCall() {
        var loadedCheckinRecords = [CheckinRecord]()
        var todoEndpoint: String = "https://breeze.xin/query.php?cid=\(courses[selectedCourse].id)"
        if (user.type == "Student") {
            todoEndpoint = todoEndpoint + "&sid=\(user.id)"
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
                    let checkinRecord: CheckinRecord = CheckinRecord()
                    checkinRecord.name = (object["name"] as? String)!
                    checkinRecord.start_time = (object["start_time"] as? String)!
                    checkinRecord.checkin_time = object["checkin_time"] as? String ?? "N/A"
                    checkinRecord.stat = (object["stat"] as? String)!
                    loadedCheckinRecords.append(checkinRecord)
                }
                checkinRecords = loadedCheckinRecords
                DispatchQueue.main.async { [unowned self] in
                    self.checkinRecordTableView.reloadData()
                }
            } catch { return }
        }
        task.resume()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return checkinRecords.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Record \(section + 1)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Name:"
            cell.detailTextLabel?.text = checkinRecords[indexPath.section].name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Start time:"
            cell.detailTextLabel?.text = checkinRecords[indexPath.section].start_time
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Checkin time:"
            cell.detailTextLabel?.text = checkinRecords[indexPath.section].checkin_time
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Checkin status:"
            cell.detailTextLabel?.text = checkinRecords[indexPath.section].stat
        }
        return cell
    }
}
