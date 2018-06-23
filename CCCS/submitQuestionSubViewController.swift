//
//  subquesViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 5/18/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

var answered : Bool = false
var answer : String = ""

class submitQuestionSubViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var answerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var chooseAnswerLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    func adjustUI() {
        if (answered) {
            chooseAnswerLabel.text = "You choosed: \(answer)"
            answerSegmentedControl.isEnabled = false
            if (answer == "A") {
                answerSegmentedControl.selectedSegmentIndex = 0
            } else if (answer == "B") {
                answerSegmentedControl.selectedSegmentIndex = 1
            } else if (answer == "C") {
                answerSegmentedControl.selectedSegmentIndex = 2
            } else if (answer == "D") {
                answerSegmentedControl.selectedSegmentIndex = 3
            }
            resultLabel.text = (answer == questions[selectedQuestion].answer ? "Correct!" : "The answer is \(questions[selectedQuestion].answer)")
            submitButton.isHidden = true
        } else {
            chooseAnswerLabel.text = "Choose your answer:"
            answerSegmentedControl.isEnabled = true
            answerSegmentedControl.selectedSegmentIndex = 0
            resultLabel.text = ""
            submitButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustUI()
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
    
    func makeSubmitAnswerCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/question/student/submitAnswer.php?sid=\(user.id)&password=\(user.password)&qid=\(questions[selectedQuestion].id)&answer=\(answer)".replacingOccurrences(of: " ", with: "+"))!)
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
                    answered = true
                    DispatchQueue.main.async { [unowned self] in
                        self.adjustUI()
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
    
    @IBAction func submitAnswer(_ sender: UIButton) {
        if (answerSegmentedControl.selectedSegmentIndex == 0) {
            answer = "A"
        } else if (answerSegmentedControl.selectedSegmentIndex == 1) {
            answer = "B"
        } else if (answerSegmentedControl.selectedSegmentIndex == 2) {
            answer = "C"
        } else if (answerSegmentedControl.selectedSegmentIndex == 3) {
            answer = "D"
        }
        makeSubmitAnswerCall()
    }
}
