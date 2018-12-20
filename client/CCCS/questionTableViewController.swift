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
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var selectedCourse: Course = Course([:])
    var currentLessonLid: Int = -1
    var questionListAll = [Question]()
    var questionListCnt = [Question]()
    var selectedQuestion = Question([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (selectedCourse.lessonlist.count != 0 &&
            selectedCourse.lessonlist[0].end_time == "") {
            currentLessonLid = selectedCourse.lessonlist[0].lid
        }
        if (user.type == "Student" || currentLessonLid == -1) {
            navigationItem.rightBarButtonItem = nil
        }
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshData),for: .valueChanged)
        refreshControl!.attributedTitle = NSAttributedString(string: "Loading")
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func refreshData() {
        refreshControl!.beginRefreshing()
        makeGetQuestionListCall()
    }
    
    @IBAction func filterValueChanged(_ sender: Any) {
        questionTableView.reloadData()
    }
    
    func makeGetQuestionListCall() {
        let str = "\(serverDir)/getQuestionList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&cid=\(selectedCourse.cid)"
        let urlRequest = URLRequest(url: URL(string: str)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.refreshControl!.endRefreshing()
            }
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
                    self.questionListAll.removeAll()
                    self.questionListCnt.removeAll()
                    for questionDic in responseDic["info"] as! [[String : Any]] {
                        let question = Question(questionDic)
                        self.questionListAll.append(question)
                        if (question.lid == self.currentLessonLid) {
                            self.questionListCnt.append(question)
                        }
                    }
                    DispatchQueue.main.async {
                        self.questionTableView.reloadData()
                    }
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (filterSegmentedControl.selectedSegmentIndex == 0) {
            return questionListCnt.count
        } else {
            return questionListAll.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Question \(section)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none

        if (filterSegmentedControl.selectedSegmentIndex == 0) {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Description:"
                cell.detailTextLabel?.text = questionListCnt[indexPath.section].description
                
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Raised time:"
                cell.detailTextLabel?.text = questionListCnt[indexPath.section].raised_time
            } else {
                cell.textLabel?.text = "Details:"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Description:"
                cell.detailTextLabel?.text = questionListAll[indexPath.section].description
                
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Raised time:"
                cell.detailTextLabel?.text = questionListAll[indexPath.section].raised_time
            } else {
                cell.textLabel?.text = "Details:"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            if (filterSegmentedControl.selectedSegmentIndex == 0) {
                selectedQuestion = self.questionListCnt[indexPath.section]
            } else {
                selectedQuestion = self.questionListAll[indexPath.section]
            }
            self.performSegue(withIdentifier: "segueToQuestionDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is raiseQuestionViewController {
            let t = segue.destination as? raiseQuestionViewController
            t?.currentLesson = self.selectedCourse.lessonlist[0]
        }
        if segue.destination is questionDetailViewController {
            let t = segue.destination as? questionDetailViewController
            t?.selectedQuestion = self.selectedQuestion
        }
    }
}
