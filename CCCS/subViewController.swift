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
    @IBOutlet weak var requestButton: UIButton!
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var cntLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user.type == "Student") {
            mainButton.setTitle("Check-in", for: .normal)
            requestButton.setTitle("Request for Leave", for: .normal)
        } else {
            requestButton.setTitle("Check Request", for: .normal)
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
        let todoEndpoint: String = "https://breeze.xin/checkin.php?sid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)"
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
        let todoEndpoint: String = "https://breeze.xin/startClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)&latitude=\(latitude)&longitude=\(longitude)"
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
        let todoEndpoint: String = "https://breeze.xin/stopClass.php?tid=\(user.id)&password=\(user.password)&cid=\(courses[selectedCourse].id)"
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
    
    
    @IBAction func requestButton(_ sender: UIButton)
    {
        //makeGetReason()
          print("1num:\(atests.count)empty?:\(atests.isEmpty)")
        if user.type=="Student" && (atests.isEmpty){
            print("2num:\(atests.count)empty?:\(atests.isEmpty)")
                studetRequest()
        }else{
           // teacherCheckrequest()
        }
    }
    
    
    func studetRequest() {
        let altervc = UIAlertController(title: "Enter your reason", message: "", preferredStyle: .alert)
        altervc.addTextField { (textField) in textField.placeholder="some reason"}
        let submitAction=UIAlertAction(title: "Submit", style: .default, handler:{
            (alter)->Void in
            let somereason  = altervc.textFields![0] as UITextField
            let text:String=somereason.text!
            print("\(courses[selectedCourse].name)    reason :\(text)")
            var todoEndpoint: String = "https://breeze.xin/studentRequest.php?sid=\(user.id)&cid=\(courses[selectedCourse].id)&state=notAllowed&reason=\(text)&password=\(user.password)"
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
                        DispatchQueue.main.async { [unowned self] in
                            courses[selectedCourse].started = true
                            self.mainButton.setTitle("Stop", for: .normal)
                            self.navigationController?.popViewController(animated: true)
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
        } )
        let cancelAction=UIAlertAction(title: "Cancel", style: .cancel, handler: {(_)in})
        
        altervc.addAction(cancelAction)
        altervc.addAction(submitAction)
        altervc.view.tintColor=UIColor.black
        present(altervc,animated: true)
        
    }
    
    func teacherCheckrequest()  {
        
    }
}


