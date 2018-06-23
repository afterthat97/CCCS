//
//  questionDetailTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/16/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

var selectedQuestion: Int = 0

class submitQuestionTableViewController: UITableViewController {
    @IBOutlet var showcontainer: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Question \(questions[selectedQuestion].id)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showcontainer.reloadData()
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
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Content: " + questions[selectedQuestion].content
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "A: " + questions[selectedQuestion].optionA
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "B: " + questions[selectedQuestion].optionB
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "C: " + questions[selectedQuestion].optionC
        } else if (indexPath.row == 4) {
            cell.textLabel?.text = "D: " + questions[selectedQuestion].optionD
        }
        return cell
    }
}
