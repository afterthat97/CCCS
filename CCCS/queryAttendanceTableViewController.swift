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

class queryAttendanceTableViewController: UITableViewController {

    @IBOutlet weak var checkinRecordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return checkinRecords.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Record \(section + 1)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
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
