//
//  addCourseViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/30/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class addCourseViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        courseNameTextField.delegate = self
        creditTextField.delegate = self
        placeTextField.delegate = self
        
        if (user.type == "Student") {
            creditTextField.placeholder = "Teacher Name";
            creditTextField.keyboardType = UIKeyboardType(rawValue: 1)!;
            placeTextField.isHidden = true;
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
    
    func makeStudentAddCourseCall(_ name : String, _ teacher : String) {
        let todoEndpoint: String = "https://breeze.xin/addCourse.php?sid=\(user.id)&password=\(user.password)&name=\(name)&teacher=\(teacher)"
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
                return
            }
        }
        task.resume()
    }
    
    func makeTeacherAddCourseCall(_ name : String, _ place : String, _ credit : String) {
        let todoEndpoint: String = "https://breeze.xin/addCourse.php?tid=\(user.id)&password=\(user.password)&name=\(name)&place=\(place)&credit=\(credit)"
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
    
    @IBAction func addCourse(_ sender: UIButton) {
        if (courseNameTextField.text! == "") {
            self.showAlert("Error", "Course name cannot be empty")
        } else if (creditTextField.text! == "") {
            self.showAlert("Error", "Credit cannot be empty")
        } else if (placeTextField.isHidden == false && placeTextField.text! == "") {
            self.showAlert("Error", "Place cannot be empty")
        } else if (user.type == "Student") {
            makeStudentAddCourseCall(courseNameTextField.text!, creditTextField.text!)
        } else {
            makeTeacherAddCourseCall(courseNameTextField.text!, placeTextField.text!, creditTextField.text!)
        }
    }
}
