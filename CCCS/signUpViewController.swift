//
//  signUpViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/25/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class signUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var realnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        realnameTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
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
    
    func makeSignUpCall(_ username: String, _ password : String, _ type : String, _ gender : String, _ name : String) {
        let todoEndpoint: String = "https://breeze.xin/signup.php?username=\(username)&password=\(password)&type=\(type)&gender=\(gender)&name=\(name)"
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
    
    @IBAction func signUp(_ sender: UIButton) {
        if (usernameTextField.text == "") {
            showAlert("Error", "Username cannot be empty.")
        } else if (realnameTextField.text == "") {
            showAlert("Error", "Real name cannot be empty.")
        } else if (passwordTextField.text == "") {
            showAlert("Error", "Password cannot be empty.")
        } else if (passwordTextField.text != retypePasswordTextField.text) {
            showAlert("Error", "Two passwords must match.")
        } else {
            var type: String = "Teacher";
            var gender : String = "Female";
            if (roleSegmentedControl.selectedSegmentIndex == 0) { type = "Student"; }
            if (sexSegmentedControl.selectedSegmentIndex == 0) { gender = "Male"; }
            makeSignUpCall(usernameTextField.text!, passwordTextField.text!, type, gender, realnameTextField.text!);
        }
    }
}
