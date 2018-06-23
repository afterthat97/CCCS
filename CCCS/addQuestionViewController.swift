//
//  addQuestionViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/14/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class addQuestionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var questionContentTextField: UITextField!
    @IBOutlet weak var optionATextField: UITextField!
    @IBOutlet weak var optionBTextField: UITextField!
    @IBOutlet weak var optionCTextField: UITextField!
    @IBOutlet weak var optionDTextField: UITextField!
    @IBOutlet weak var chooseSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        questionContentTextField.delegate = self
        optionATextField.delegate = self
        optionBTextField.delegate = self
        optionCTextField.delegate = self
        optionDTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (user.type == "Teacher" && courses[selectedCourse].started == false) {
            showAlert("Hint", "Class not started, you cannot raise questions.")
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }

    func makeAddQuestionCall(_ content : String, _ optionA : String, _ optionB : String, _ optionC : String, _ optionD : String, _ answer : String) {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/question/teacher/addQuestion.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&content=\(content)&optionA=\(optionA)&optionB=\(optionB)&optionC=\(optionC)&optionD=\(optionD)&answer=\(answer)".replacingOccurrences(of: " ", with: "+"))!)
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
                let info = data["info"] as! String
                if (code == 0) {
                    let newQuestion : Question = Question()
                    newQuestion.id = Int(data["qid"] as! String)!
                    newQuestion.raised_time = data["raised_time"] as! String
                    newQuestion.content = content
                    newQuestion.optionA = optionA
                    newQuestion.optionB = optionB
                    newQuestion.optionC = optionC
                    newQuestion.optionD = optionD
                    newQuestion.answer = answer
                    questions.append(newQuestion)
                    DispatchQueue.main.async { [unowned self] in
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", info)
                } else {
                    self.showAlert("Error", info)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    @IBAction func raiseQuestion(_ sender: UIButton) {
        if (questionContentTextField.text! == "") {
            self.showAlert("Error", "Question description cannot be empty!")
        } else if (optionATextField.text! == "") {
            self.showAlert("Error", "Option A cannot be empty!")
        } else if (optionBTextField.text! == "") {
            self.showAlert("Error", "Option B cannot be empty")
        } else if (optionCTextField.text! == "") {
            self.showAlert("Error", "Optino C cannot be empty!")
        } else if (optionDTextField.text! == "") {
            self.showAlert("Error", "Option D cannot be empty!")
        } else {
            var answer: String = "A";
            if (chooseSegmentedControl.selectedSegmentIndex == 1) { answer = "B"; }
            if (chooseSegmentedControl.selectedSegmentIndex == 2) { answer = "C"; }
            if (chooseSegmentedControl.selectedSegmentIndex == 3) { answer = "D"; }
            makeAddQuestionCall(questionContentTextField.text!, optionATextField.text!, optionBTextField.text!, optionCTextField.text!, optionDTextField.text!, answer)
        }
    }
}
