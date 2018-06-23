//
//  analyzeStatisticsTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/31/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

var n_submitted : Int = 0
var n_correct : Int = 0
var n_A : Int = 0
var n_B : Int = 0
var n_C : Int = 0
var n_D : Int = 0

class analyzeStatisticsTableViewController: UITableViewController {
    @IBOutlet var analysisTableView: UITableView!
    
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.selectionStyle = .none
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Content: "
                cell.detailTextLabel?.text = questions[selectedQuestion].content
            } else if (indexPath.row == 1) {
                cell.textLabel?.text = "A: "
                cell.detailTextLabel?.text = questions[selectedQuestion].optionA
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "B: "
                cell.detailTextLabel?.text = questions[selectedQuestion].optionB
            } else if (indexPath.row == 3) {
                cell.textLabel?.text = "C: "
                cell.detailTextLabel?.text = questions[selectedQuestion].optionC
            } else if (indexPath.row == 4) {
                cell.textLabel?.text = "D: "
                cell.detailTextLabel?.text = questions[selectedQuestion].optionD
            } else if (indexPath.row == 5) {
                cell.textLabel?.text = "Answer: "
                cell.detailTextLabel?.text = questions[selectedQuestion].answer
            }
        } else {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Submitted: "
                cell.detailTextLabel?.text = String(n_submitted)
            } else if (indexPath.row == 1) {
                cell.textLabel?.text = "A: "
                cell.detailTextLabel?.text = String(n_A)
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "B: "
                cell.detailTextLabel?.text = String(n_B)
            } else if (indexPath.row == 3) {
                cell.textLabel?.text = "C: "
                cell.detailTextLabel?.text = String(n_C)
            } else if (indexPath.row == 4) {
                cell.textLabel?.text = "D: "
                cell.detailTextLabel?.text = String(n_D)
            } else if (indexPath.row == 5) {
                cell.textLabel?.text = "Accuracy: "
                cell.detailTextLabel?.text = "\(String(n_correct * 100 / (n_submitted == 0 ? 1 : n_submitted)))%"
            }
        }
        return cell
    }
}
