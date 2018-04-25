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
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeSignUpCall(_ username: String, _ password : String, _ type : String, _ sex : String, _ name : String) {
        let todoEndpoint: String = "https://masterliu.net/signup.php?username=" + username + "&password=" + password + "&type=" + type + "&sex=" + sex + "&name=" + name;
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Failed to contact the server.")
                return
            }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                let code = todo!["code"] as? Int
                let error = todo!["error"] as? String
                if (code == 0) {
                    DispatchQueue.main.async { [unowned self] in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.showAlert("Success", "You have registered successfully.")
                } else {
                    self.showAlert("Error", error!)
                }
            } catch {
                self.showAlert("Error", "Failed to contact the server.")
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
            var type: String = "1";
            var sex : String = "1";
            if (roleSegmentedControl.selectedSegmentIndex == 0) { type = "0"; }
            if (sexSegmentedControl.selectedSegmentIndex == 0) { sex = "0"; }
            makeSignUpCall(usernameTextField.text!, passwordTextField.text!, type, sex, realnameTextField.text!);
        }
    }
    
}
