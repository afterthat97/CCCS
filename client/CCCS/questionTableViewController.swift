//
//  questionTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/19/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class questionTableViewController: UITableViewController {
    @IBOutlet var questionTableView: UITableView!
    
    var currentLesson = Lesson([:])
    var questionList = [Question]()
    var selectedQuestion = Question([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user.type == "Student" {
            navigationItem.rightBarButtonItem = nil
        }
        makeGetQuestionListCall()
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }

    func makeGetQuestionListCall() {
        let str = "\(serverDir)/getQuestionList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&lid=\(currentLesson.lid)"
        let urlRequest = URLRequest(url: URL(string: str)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Response Error.")
                return
            }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                let responseDic = responseJson as! [String : Any]
                if (responseDic["code"] as! Int == 1) {
                    self.showAlert("Error", responseDic["info"] as! String)
                } else {
                    self.questionList.removeAll()
                    for questionDic in responseDic["info"] as! [[String : Any]] {
                        self.questionList.append(Question(questionDic))
                    }
                    DispatchQueue.main.async { self.questionTableView.reloadData() }
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return questionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Question \(section)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Description:"
            cell.detailTextLabel?.text = questionList[indexPath.section].description
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Raised time:"
            cell.detailTextLabel?.text = questionList[indexPath.section].raised_time
        } else {
            cell.textLabel?.text = "Details:"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            selectedQuestion = self.questionList[indexPath.section]
            self.performSegue(withIdentifier: "segueToQuestionDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is raiseQuestionViewController {
            let t = segue.destination as? raiseQuestionViewController
            t?.currentLesson = self.currentLesson
        }
        if segue.destination is questionDetailViewController {
            let t = segue.destination as? questionDetailViewController
            t?.selectedQuestion = self.selectedQuestion
        }
    }
}
