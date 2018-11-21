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
        self.navigationItem.title = user.realname
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.selectionStyle = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Username:"
            cell.detailTextLabel?.text = user.username
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Realname:"
            cell.detailTextLabel?.text = user.realname
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Gender:"
            cell.detailTextLabel?.text = user.gender
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Type:"
            cell.detailTextLabel?.text = user.type
        }
        return cell
    }
}
