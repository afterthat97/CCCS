//
//  subViewController.swift
//  CCCS
//
//  Created by Alfred Liu on 4/30/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreLocation

class courseDetailSubViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var queryAttendanceButton: UIButton!
    @IBOutlet weak var raiseQuestionButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var cntLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user.type == "Student") {
            mainButton.setTitle("Check-in", for: .normal)
        } else {
            if (courses[selectedCourse].started) {
                mainButton.setTitle("Stop", for: .normal)
            } else {
                mainButton.setTitle("Start", for: .normal)
            }
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        cntLocation = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cntLocation = locations[locations.count - 1]
    }
    
    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func makeCheckInCall(_ latitude: String, _ longitude : String) {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/checkin/checkin.php?sid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)".replacingOccurrences(of: " ", with: "+"))!)
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
                let info = data["info"] as! String
                if (code == 0) {
                    DispatchQueue.main.async { [unowned self] in
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", info)
                } else {
                    self.showAlert("Error", info)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    func makeStartClassCall(_ latitude: String, _ longitude : String) {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/checkin/startClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)".replacingOccurrences(of: " ", with: "+"))!)
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
                let info = data["info"] as! String
                if (code == 0) {
                    DispatchQueue.main.async { [unowned self] in
                        courses[selectedCourse].started = true
                        self.mainButton.setTitle("Stop", for: .normal)
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", info)
                } else {
                    self.showAlert("Error", info)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    func makeStopClassCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/checkin/stopClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)".replacingOccurrences(of: " ", with: "+"))!)
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
                let info = data["info"] as! String
                if (code == 0) {
                    DispatchQueue.main.async { [unowned self] in
                        courses[selectedCourse].started = false
                        self.mainButton.setTitle("Start", for: .normal)
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.showAlert("Success", info)
                } else {
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
                        self.makeCheckInCall(String(self.cntLocation.coordinate.latitude), String(self.cntLocation.coordinate.longitude))
                    }
                }
            }
        } else {
            self.showAlert("Touch ID not available", "Your device is not configured for Touch ID.")
        }
    }
    
    @IBAction func mainEvent(_ sender: UIButton) {
        if (user.type == "Student") {
            if (courses[selectedCourse].started) {
                authenticateUser()
            } else {
                self.showAlert("Error", "Class not started")
            }
        } else {
            if (courses[selectedCourse].started) {
                makeStopClassCall()
            } else {
                makeStartClassCall(String(cntLocation.coordinate.latitude), String(cntLocation.coordinate.longitude))
            }
        }
    }
    
    func makeGetCheckInRecordCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/query/queryAttendance.php?cid=\(courses[selectedCourse].id)&id=\(user.id)&type=\(user.type)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [[String : Any]]
                var loadedCheckinRecords = [CheckinRecord]()
                for object in data {
                    let checkinRecord: CheckinRecord = CheckinRecord()
                    checkinRecord.name = (object["name"] as! String)
                    checkinRecord.start_time = (object["start_time"] as! String)
                    checkinRecord.checkin_time = object["checkin_time"] as? String ?? "N/A"
                    checkinRecord.stat = (object["stat"] as! String)
                    loadedCheckinRecords.append(checkinRecord)
                }
                checkinRecords = loadedCheckinRecords
                DispatchQueue.main.async { [unowned self] in
                    self.performSegue(withIdentifier: "segueToQueryAttendanceTableView", sender: self)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    @IBAction func queryAttendanceEvent(_ sender: UIButton) {
        makeGetCheckInRecordCall()
    }
    
    func makeGetQuestionListCall() {
        let urlRequest = URLRequest(url: URL(string: "https://masterliu.net/cccs/question/getList.php?cid=\(courses[selectedCourse].id)".replacingOccurrences(of: " ", with: "+"))!)
        let urlConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlConfig)
        let task = urlSession.dataTask(with: urlRequest) { (responseData, response, error) in
            guard let rawData = responseData else {
                self.showAlert("Error", "Data error.")
                return
            }
            do {
                let data = try JSONSerialization.jsonObject(with: rawData, options: []) as! [[String : Any]]
                var loadedQuestions = [Question]()
                for object in data {
                    let question : Question = Question()
                    question.id = Int((object["qid"] as! String))!
                    question.raised_time = (object["raised_time"] as! String)
                    question.content = (object["content"] as! String)
                    question.optionA = (object["optionA"] as! String)
                    question.optionB = (object["optionB"] as! String)
                    question.optionC = (object["optionC"] as! String)
                    question.optionD = (object["optionD"] as! String)
                    question.answer = (object["answer"] as! String)
                    loadedQuestions.append(question)
                }
                questions = loadedQuestions
                DispatchQueue.main.async { [unowned self] in
                    self.performSegue(withIdentifier: "segueToQuestionTableView", sender: self)
                }
            } catch {
                self.showAlert("Error", "JSON Error.")
                return
            }
        }
        task.resume()
    }
    
    @IBAction func raiseQuestionEvent(_ sender: UIButton) {
        makeGetQuestionListCall()
    }
}
