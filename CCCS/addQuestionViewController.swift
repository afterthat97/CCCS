//
//  addQuestionViewController.swift
//  CCCS
//
//  Created by 浦清风 on 5/14/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class addQuestionViewController: UIViewController,UITextFieldDelegate{

    
    @IBOutlet weak var questioncontent: UITextField!
    @IBOutlet weak var Achoose: UITextField!
    @IBOutlet weak var Bchoose: UITextField!
    @IBOutlet weak var Cchoose: UITextField!
    @IBOutlet weak var Dchoose: UITextField!
    @IBOutlet weak var choose: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        questioncontent.delegate = self
        Achoose.delegate = self
        Bchoose.delegate = self
        Cchoose.delegate = self
        Dchoose.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func makeTeacherAddQuestionCall(_ content:String,_ Achoice:String,_ Bchoice:String,_ Cchoice:String,_ Dchoice:String,_ Choose:String) {
        let todoEndpoint: String = "https://breeze.xin/addQuestion.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&quescontent=\(content)&Achoice=\(Achoice)&Bchoice=\(Bchoice)&Cchoice=\(Cchoice)&Dchoice=\(Dchoice)&Choose=\(Choose)"
        print(todoEndpoint)
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Data Error.")
                return
            }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                let code = todo!["code"] as? Int
                let info = todo!["info"] as? String
                if (code == 0) {
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", info!)
                } else {
                    self.showAlert("Error", info!)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    @IBAction func addquestion(_ sender: UIButton) {
        
        
        if (questioncontent.text! == "") {
            self.showAlert("Error", "Question description cannot be empty")
        } else if (Achoose.text! == "") {
            self.showAlert("Error", "At least two options!")
        } else if (Bchoose.text! == "") {
            self.showAlert("Error", "At least two options!")
        } else {
            var correct: String = "A";
            
            if (choose.selectedSegmentIndex == 1) { correct = "B"; }
            if (choose.selectedSegmentIndex == 2) { correct = "C"; }
            if (choose.selectedSegmentIndex == 3) { correct = "D"; }
            
            makeTeacherAddQuestionCall(questioncontent.text!, Achoose.text!, Bchoose.text!, Cchoose.text!, Dchoose.text!, correct)
        }
    }
}
