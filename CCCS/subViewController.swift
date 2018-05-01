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

class subViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var queryButton: UIButton!
    
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let todoEndpoint: String = "https://masterliu.net/checkin.php?sid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)"
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
                    DispatchQueue.main.async { [unowned self] in
                        courses[selectedCourse].started = true
                        self.mainButton.setTitle("Stop", for: .normal)
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
    
    func makeStartClassCall(_ latitude: String, _ longitude : String) {
        let todoEndpoint: String = "https://masterliu.net/startClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)"
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
                    DispatchQueue.main.async { [unowned self] in
                        courses[selectedCourse].started = true
                        self.mainButton.setTitle("Stop", for: .normal)
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
    
    func makeStopClassCall() {
        let todoEndpoint: String = "https://masterliu.net/stopClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)"
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
                    DispatchQueue.main.async { [unowned self] in
                        courses[selectedCourse].started = false
                        self.mainButton.setTitle("Start", for: .normal)
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
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identification"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.makeCheckInCall(String(self.cntLocation.coordinate.latitude), String(self.cntLocation.coordinate.longitude))
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
    
    func studentCheckIn() {
        authenticateUser()
    }
    
    func teacherStartClass() {
        makeStartClassCall(String(cntLocation.coordinate.latitude), String(cntLocation.coordinate.longitude))
    }
    
    func teacherStopClass() {
        makeStopClassCall()
    }
    
    @IBAction func mainEvent(_ sender: UIButton) {
        if (user.type == "Student") {
            if (courses[selectedCourse].started) {
                studentCheckIn()
            } else {
                self.showAlert("Error", "Class not started")
            }
        } else {
            if (courses[selectedCourse].started) {
                teacherStopClass()
            } else {
                teacherStartClass()
            }
        }
    }
    
    @IBAction func queryEvent(_ sender: UIButton) {
        makeGetCheckInRecordCall()
        self.performSegue(withIdentifier: "segueToQuery", sender: self)
    }
    
}
