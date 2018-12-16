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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = user.realname
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 4
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.selectionStyle = .none
        if (indexPath.section == 0) {
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
        } else {
            cell.textLabel?.text = "ChangeInfo:"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            self.performSegue(withIdentifier: "segueToChangeInfo", sender: self)
        }
    }
}
