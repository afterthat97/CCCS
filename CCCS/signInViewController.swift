//
//  ViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/25/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication

class User {
    var id : Int = 0
    var username : String = ""
    var password : String = ""
    var name : String = ""
    var type : String = ""
    var gender : String = ""
    var register_date : String = ""
}

var user : User = User()

class signInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func makeSignInCall() {
        var todoEndpoint: String = "https://breeze.xin/signin.php?username=\(user.username)&password=\(user.password)&type=\(user.type)"
        todoEndpoint = todoEndpoint.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                let code = todo!["code"] as? Int
                let info = todo!["info"] as? String
                if (code == 0) {
                    user.id = (todo!["id"] as? Int)!
                    user.name = (todo!["name"] as? String)!
                    user.gender = (todo!["gender"] as? String)!
                    user.register_date = (todo!["register_date"] as? String)!
                    makeGetCourseCall()
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: "segueToMain", sender: self)
                    }
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
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identification"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.makeSignInCall()
                    } else {
                        let ac = UIAlertController(title: "Error", message: "Authentication failed", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if (usernameTextField.text == "") {
            showAlert("Error", "Username cannot be empty.")
        } else if (passwordTextField.text == "") {
            showAlert("Error", "Password cannot be empty.")
        } else {
            user.type = "Teacher"
            if (roleSegmentedControl.selectedSegmentIndex == 0) {
                user.type = "Student"
            }
            user.username = usernameTextField.text!
            user.password = passwordTextField.text!
            authenticateUser()
        }
    }
}

