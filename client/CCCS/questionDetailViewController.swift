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
    @IBOutlet weak var submitButton: UIButton!
    
    var selectedQuestion = Question([:])
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
            submitButton.isHidden = true
        }
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
    
    func makeSubmitAnswerCall(_ choice: Int) {
        let urlString = "\(serverDir)/answerQuestion.php?username=\(user.username)&password=\(user.password)&type=\(user.type)&qid=\(self.selectedQuestion.qid)&choice=\(choice)&latitude=\(self.cntLocation.coordinate.latitude)&longitude=\(self.cntLocation.coordinate.longitude)"
        let urlRequest = URLRequest(url: URL(string: urlString)!)
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
                if (responseDic["code"] as! Int == 0) {
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
    
    @IBAction func submitAnswer(_ sender: Any) {
        if questionTableView.indexPathForSelectedRow?.section == nil {
            self.showAlert("Error", "You must select an option.")
        } else {
            makeSubmitAnswerCall((questionTableView.indexPathForSelectedRow?.section)!)
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
