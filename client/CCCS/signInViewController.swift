//
//  ViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/25/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication

class signInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        activityIndicator.hidesWhenStopped = true
        makeTestConnectionCall()
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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeTestConnectionCall() {
        let str = "\(serverDir)/testConnection.php"
        let urlRequest = URLRequest(url: URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Failed to connect to server.\nCheck your network connection.")
                return
            }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                let responseDic = responseJson as! [String : Any]
                if (responseDic["code"] as! Int == 1) {
                    self.showAlert("Error", "\(responseDic["info"] as! String)\nDid you run \(serverDir)/setup.php to build the database?")
                }
            } catch _ {
                self.showAlert("Error", "Failed to connect to server.\nIs 'serverDir' in 'customDataStructure.swift' correct?")
                return
            }
        }
        task.resume()
    }
    
    func makeSignInCall(_ username : String, _ password : String, _ type : String) {
        let str = "\(serverDir)/signin.php?username=\(username)&password=\(password)&type=\(type)"
        let urlRequest = URLRequest(url: URL(string: str)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.signInButton.isEnabled = true
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
                    let userInfoDic = responseDic["info"] as! [String : Any]
                    user = User(type, userInfoDic)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "segueToCourseList", sender: self)
                    }
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identification") {
                [unowned self] success, error in
                DispatchQueue.main.async {
                    if (success) {
                        self.signInButton.isEnabled = false
                        self.activityIndicator.startAnimating()
                        if (self.roleSegmentedControl.selectedSegmentIndex == 0) {
                            self.makeSignInCall(self.usernameTextField.text!, self.passwordTextField.text!, "Student")
                        } else {
                            self.makeSignInCall(self.usernameTextField.text!, self.passwordTextField.text!, "Teacher")
                        }
                    }
                }
            }
        } else {
            self.showAlert("Touch ID / Face ID not available", "Your device is not configured for Touch ID / Face ID.")
            DispatchQueue.main.async {
                self.signInButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if (usernameTextField.text == "") {
            showAlert("Error", "Username cannot be empty.")
        } else if (passwordTextField.text == "") {
            showAlert("Error", "Password cannot be empty.")
        } else {
            authenticateUser()
        }
    }
}
