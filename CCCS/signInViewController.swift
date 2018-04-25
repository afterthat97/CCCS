//
//  ViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/25/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

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
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeSignInCall(_ username: String, _ password : String, _ type : String) {
        let todoEndpoint: String = "https://masterliu.net/signin.php?username=" + username + "&password=" + password + "&type=" + type;
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
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let meTableViewController =
                            storyboard.instantiateViewController(withIdentifier: "tabBarController")
                        self.navigationController?.present(meTableViewController, animated: true)
                    }
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
    
    @IBAction func signIn(_ sender: UIButton) {
        if (usernameTextField.text == "") {
            showAlert("Error", "Username cannot be empty.")
        } else if (passwordTextField.text == "") {
            showAlert("Error", "Password cannot be empty.")
        } else {
            var type: String = "1";
            if (roleSegmentedControl.selectedSegmentIndex == 0) { type = "0"; }
            makeSignInCall(usernameTextField.text!, passwordTextField.text!, type)
        }
    }
}

