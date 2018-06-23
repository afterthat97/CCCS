//
//  QuestionTableViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/16/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class Question {
    var id : Int = 0
    var raised_time : String = ""
    var content : String = ""
    var optionA : String = ""
    var optionB : String = ""
    var optionC : String = ""
    var optionD : String = ""
    var answer : String = ""
}

var questions = [Question]()

class questionTableViewController: UITableViewController {
    @IBOutlet weak var questionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user.type == "Student") {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        questionTableView.reloadData()
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
        return questions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Question \(questions[section].id)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if (indexPath.section >= questions.count) { return cell }
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.selectionStyle = .none
            cell.textLabel?.text = "Content:"
            cell.detailTextLabel?.text = questions[indexPath.section].content
        } else if (indexPath.row == 1) {
            cell.selectionStyle = .none
            cell.textLabel?.text = "Raised time:"
            cell.detailTextLabel?.text = questions[indexPath.section].raised_time
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "More:"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func makeGetQuestionCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/question/student/getQuestion.php?sid=\(user.id)&password=\(user.password)&qid=\(questions[selectedQuestion].id)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [String : Any]
                let code = data["code"] as! Int
                if (code == 0) {
                    answered = data["answered"] as! Bool
                    if (answered) {
                        answer = data["answer"] as! String
                    }
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: "segueToSubmitQuestionTableView", sender: self)
                    }
                } else {
                    let info = data["info"] as! String
                    print(info)
                    self.showAlert("Error", info)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    func makeGetAnalysisCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/question/teacher/getQuestion.php?tid=\(user.id)&password=\(user.password)&qid=\(questions[selectedQuestion].id)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [String : Any]
                let code = data["code"] as! Int
                if (code == 0) {
                    n_submitted = Int(data["submitted"] as! String)!
                    n_A = Int(data["A"] as! String)!
                    n_B = Int(data["B"] as! String)!
                    n_C = Int(data["C"] as! String)!
                    n_D = Int(data["D"] as! String)!
                    if (questions[selectedQuestion].answer == "A") {
                        n_correct = n_A
                    } else if (questions[selectedQuestion].answer == "B") {
                        n_correct = n_B
                    } else if (questions[selectedQuestion].answer == "C") {
                        n_correct = n_C
                    } else if (questions[selectedQuestion].answer == "D") {
                        n_correct = n_D
                    }
                } else {
                    let info = data["info"] as! String
                    self.showAlert("Error", info)
                }
                DispatchQueue.main.async { [unowned self] in
                    self.performSegue(withIdentifier: "segueToAnalyzeStatisticsTableView", sender: self)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            selectedQuestion = indexPath.section
            if (user.type == "Student") {
                makeGetQuestionCall()
            } else {
                makeGetAnalysisCall()
            }
        }
    }
}
