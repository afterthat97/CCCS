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
    
    func makeGetCourseCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/course/getCourse.php?id=\(user.id)&type=\(user.type)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [[String : Any]]
                var loadedCourses = [Course]()
                for object in data {
                    let course : Course = Course()
                    course.id = Int(object["cid"] as! String)!
                    course.name = (object["name"] as! String)
                    course.place = (object["place"] as! String)
                    course.credit = Int(object["credit"] as! String)!
                    course.teacherName = (object["teacherName"] as! String)
                    course.teacherGender = (object["teacherGender"] as! String)
                    course.started = Int((object["started"] as! String))! == 1 ? true : false
                    if (course.started) {
                        course.start_time = (object["start_time"] as! String)
                    } else {
                        course.start_time = "N/A"
                    }
                    loadedCourses.append(course)
                }
                courses = loadedCourses
                DispatchQueue.main.async { [unowned self] in
                    self.performSegue(withIdentifier: "segueToMain", sender: self)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    func makeSignInCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/signin/signin.php?username=\(user.username)&password=\(user.password)&type=\(user.type)".replacingOccurrences(of: " ", with: "+"))!)
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
                if (code == 0) {
                    user.id = Int((data["id"] as! String))!
                    user.name = (data["name"] as! String)
                    user.gender = (data["gender"] as! String)
                    user.register_date = (data["register_date"] as! String)
                    DispatchQueue.main.async { [unowned self] in
                        self.makeGetCourseCall()
                    }
                } else {
                    let info = data["info"] as! String
                    self.showAlert("Error", info)
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
                    if (success) {
                        self.makeSignInCall()
                    }
                }
            }
        } else {
            self.showAlert("Touch ID not available", "Your device is not configured for Touch ID.")
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
