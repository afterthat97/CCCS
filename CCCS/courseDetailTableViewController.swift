//
//  courseDetailTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/30/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

var selectedCourse: Int = 0

class courseDetailTableViewController: UITableViewController {
    @IBOutlet var courseDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = courses[selectedCourse].name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.courseDetailTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Name:"
            cell.detailTextLabel?.text = courses[selectedCourse].name
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Teacher:"
            cell.detailTextLabel?.text = courses[selectedCourse].teacherName
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Gender:"
            cell.detailTextLabel?.text = courses[selectedCourse].teacherGender
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Place:"
            cell.detailTextLabel?.text = courses[selectedCourse].place
        } else if (indexPath.row == 4) {
            cell.textLabel?.text = "Credit:"
            cell.detailTextLabel?.text = String(courses[selectedCourse].credit)
        } else if (indexPath.row == 5) {
            cell.textLabel?.text = "Status:"
            cell.detailTextLabel?.text = courses[selectedCourse].started ? "Started" : "Not Started"
        } else if (indexPath.row == 6) {
            cell.textLabel?.text = "Start time:"
            cell.detailTextLabel?.text = courses[selectedCourse].start_time
        }
        return cell
    }
}
