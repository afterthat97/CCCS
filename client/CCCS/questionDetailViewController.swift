//
//  questionDetailViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 11/21/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreLocation

class questionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var questionDescriptionLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedQuestion = Question([:])
    var answerRecordList = [AnswerRecord]()
    var locationManager: CLLocationManager = CLLocationManager()
    var cntLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        cntLocation = nil
        questionDescriptionLabel.text = selectedQuestion.description
        questionTableView.tableFooterView = UIView()
        questionTableView.delegate = self
        questionTableView.dataSource = self
        if user.type == "Teacher" {
            mainButton.setTitle("Results", for: .normal)
        } else {
            mainButton.setTitle("Submit", for: .normal)
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count == 0) { return }
        cntLocation = locations[locations.count - 1]
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeGetAnswerListCall() {
        let urlString = "\(serverDir)/getAnswerList.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&qid=\(self.selectedQuestion.qid)"
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.mainButton.isEnabled = true
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
                    self.answerRecordList.removeAll()
                    for answerRecordDic in responseDic["info"] as! [[String : Any]] {
                        self.answerRecordList.append(AnswerRecord(answerRecordDic))
                    }
                    var correct_count = 0
                    for answerRecord in self.answerRecordList {
                        if answerRecord.choice == self.selectedQuestion.answer {
                            correct_count = correct_count + 1
                        }
                    }
                    self.showAlert("Info", "\(self.answerRecordList.count) student(s) answered this question, \(correct_count) of them is/are correct.")
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    func makeSubmitAnswerCall(_ choice: Int) {
        let urlString = "\(serverDir)/answerQuestion.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&qid=\(self.selectedQuestion.qid)&choice=\(choice)&latitude=\(self.cntLocation.coordinate.latitude)&longitude=\(self.cntLocation.coordinate.longitude)"
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                self.mainButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
            guard let responseData = data else {
                self.showAlert("Error", "Response Error.")
                return
            }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                let responseDic = responseJson as! [String : Any]
                if (responseDic["code"] as! Int == 0) {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", responseDic["info"] as! String)
                } else {
                    self.showAlert("Error", responseDic["info"] as! String)
                }
            } catch let parsingError {
                self.showAlert("Error", parsingError.localizedDescription)
                return
            }
        }
        task.resume()
    }
    
    @IBAction func mainEvent(_ sender: Any) {
        if user.type == "Teacher" {
            mainButton.isEnabled = false
            activityIndicator.startAnimating()
            makeGetAnswerListCall()
        } else {
            if questionTableView.indexPathForSelectedRow?.section == nil {
                self.showAlert("Error", "You must select an option.")
                return
            }
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identification") {
                    [unowned self] success, authenticationError in
                    DispatchQueue.main.async {
                        if (success) {
                            self.mainButton.isEnabled = false
                            self.activityIndicator.startAnimating()
                            self.makeSubmitAnswerCall((self.questionTableView.indexPathForSelectedRow?.section)!)
                        }
                    }
                }
            } else {
                self.showAlert("Touch ID / Face ID not available", "Your device is not configured for Touch ID / Face ID.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedQuestion.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Option \(String(UnicodeScalar(indexPath.row + 65)!)):"
        cell.detailTextLabel?.text = selectedQuestion.options[indexPath.row]
        return cell
    }
}
