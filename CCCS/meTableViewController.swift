//
//  meTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/25/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class meTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = user.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Username:";
            cell.detailTextLabel?.text = user.username
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Name:";
            cell.detailTextLabel?.text = user.name
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Gender:";
            cell.detailTextLabel?.text = user.gender
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Type:";
            cell.detailTextLabel?.text = user.type
        } else {
            cell.textLabel?.text = "Register Date:";
            cell.detailTextLabel?.text = user.register_date
        }
        return cell
    }
}
