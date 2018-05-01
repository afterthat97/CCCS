//
//  queryTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/1/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class Checkin_record {
    var name : String = ""
    var start_time : String = ""
    var checkin_time : String = ""
    var stat : String = ""
}

var checkin_records = [Checkin_record]()

func makeGetCheckInRecordCall() {
    checkin_records.removeAll()
    var todoEndpoint: String = "https://masterliu.net/query.php?cid=\(courses[selectedCourse].id)"
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
                let checkin_record: Checkin_record = Checkin_record()
                checkin_record.name = (object["name"] as? String)!
                checkin_record.start_time = (object["start_time"] as? String)!
                checkin_record.checkin_time = object["checkin_time"] as? String ?? "N/A"
                checkin_record.stat = (object["stat"] as? String)!
                checkin_records.append(checkin_record)
            }
        } catch { return }
    }
    task.resume()
}

class queryTableViewController: UITableViewController {

    @IBOutlet weak var checkinRecordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkinRecordTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return checkin_records.count
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
            cell.detailTextLabel?.text = checkin_records[indexPath.section].name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Start time:"
            cell.detailTextLabel?.text = checkin_records[indexPath.section].start_time
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Checkin time:"
            cell.detailTextLabel?.text = checkin_records[indexPath.section].checkin_time
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Checkin status:"
            cell.detailTextLabel?.text = checkin_records[indexPath.section].stat
        }
        return cell
    }
}
