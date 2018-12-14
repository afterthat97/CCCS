//
//  settingViewController.swift
//  CCCS
//
//  Created by 浦清风 on 12/13/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication

class settingViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var changeRealNameTextField: UITextField!
    @IBOutlet weak var changePasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        changeRealNameTextField.delegate = self
        changePasswordTextField.delegate = self
        

        // Do any additional setup after loading the view.
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
    
    func makeChangeInfoCall(_ new_realname : String, _ new_password : String) {
        let str = "\(serverDir)/changeInfo.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&new_realname=\(new_realname)&new_password=\(new_password)"
        let urlRequest = URLRequest(url: URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
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
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identification") {
                [unowned self] success, authenticationError in
                if (success) {
                    DispatchQueue.main.async {
                        self.makeChangeInfoCall(self.changeRealNameTextField.text!,self.changePasswordTextField.text!)
                    }
                }
            }
        } else {
            self.showAlert("Touch ID/Face ID not available", "Your device is not configured for Touch ID/Face ID.")
        }
    }

    @IBAction func changeInfo(_ sender: UIButton) {
        if (changeRealNameTextField.text! == "" && changePasswordTextField.text! == "") {
            self.showAlert("Error", "Please type in the item you want to change")
        }
        else{
            authenticateUser()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
