//
//  raiseQuestionViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/21/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication

class raiseQuestionViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var answerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var questionDescriptionTextField: UITextField!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentLesson: Lesson = Lesson([:])
    var newQuestion: Question = Question([:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionDescriptionTextField.delegate = self
        questionTableView.tableFooterView = UIView()
        questionTableView.delegate = self
        questionTableView.dataSource = self
        for i in 0..<newQuestion.options.count {
            newQuestion.options[i] = "Click to edit"
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addOption(_ sender: Any) {
        if newQuestion.options.count >= 4 {
            self.showAlert("Error", "You can set 4 options at most.")
            return
        }
        answerSegmentedControl.insertSegment(withTitle: String(UnicodeScalar(newQuestion.options.count + 65)!), at: answerSegmentedControl.numberOfSegments, animated: true)
        newQuestion.options.append("Click to edit")
        questionTableView.reloadData()
    }
    
    @IBAction func raiseQuestion(_ sender: Any) {
        if questionDescriptionTextField.text == "" {
            self.showAlert("Error", "Question description can't leave empty.")
            return
        }
        for i in 0..<newQuestion.options.count {
            if newQuestion.options[i] == "Click to edit" || newQuestion.options[i] == "" {
                self.showAlert("Error", "Option \(String(UnicodeScalar(i + 65)!)) can't leave empty.")
                return
            }
        }
        newQuestion.description = questionDescriptionTextField.text!
        newQuestion.answer = answerSegmentedControl.selectedSegmentIndex
        
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identification") {
                [unowned self] success, authenticationError in
                DispatchQueue.main.async {
                    if (success) {
                        self.mainButton.isEnabled = false
                        self.activityIndicator.startAnimating()
                        self.makeRaiseQuestionCall(self.currentLesson, self.newQuestion)
                    }
                }
            }
        } else {
            self.showAlert("Touch ID / Face ID not available", "Your device is not configured for Touch ID / Face ID.")
        }
    }
    
    func makeRaiseQuestionCall(_ lesson: Lesson, _ question: Question) {
        var str = "\(serverDir)/raiseQuestion.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&lid=\(lesson.lid)&description=\(question.description)&answer=\(question.answer)"
        for i in 0..<newQuestion.options.count {
            str = str + "&option\(i)=\(newQuestion.options[i])"
        }
        let urlRequest = URLRequest(url: URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.mainButton.isEnabled = true
                self.activityIndicator.stopAnimating()
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
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", responseDic["info"] as! String)
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newQuestion.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Option \(String(UnicodeScalar(indexPath.row + 65)!)):"
        cell.detailTextLabel?.text = newQuestion.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            answerSegmentedControl.removeSegment(at: answerSegmentedControl.numberOfSegments - 1, animated: true)
            newQuestion.options.remove(at: indexPath.row)
            self.questionTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit", message: "Edit Option:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { _ in })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.newQuestion.options[indexPath.row] = (alert.textFields?.first?.text)!
            self.questionTableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}
