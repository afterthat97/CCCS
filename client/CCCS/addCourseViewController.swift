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
    @IBOutlet weak var mainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseNameTextField.delegate = self
        creditTextField.delegate = self
        placeTextField.delegate = self
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
    
    func makeAddCourseCall(_ name : String, _ credit : String, _ place : String) {
        let url = URL(string: "\(serverDir)/addCourse.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&name=\(name)&credit=\(credit)")
        let urlRequest = URLRequest(url: url!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
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
                    self.showAlert("Success", responseDic["info"] as! String)
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
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
        } else {
            makeAddCourseCall(courseNameTextField.text!, creditTextField.text!, placeTextField.text!)
        }
    }
}
