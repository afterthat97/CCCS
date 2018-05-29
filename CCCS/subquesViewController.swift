//
//  subquesViewController.swift
//  CCCS
//
//  Created by 浦清风 on 5/18/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

var outcomes=[String]()

class subquesViewController: UIViewController {

    @IBOutlet var subques: UIView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var chooseAnswer: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user.type == "Student") {
            mainButton.setTitle("Answer", for: .normal)
        } else {
           chooseAnswer.isHidden = true
           mainButton.setTitle("Analysis", for: .normal)
            
        }
        // Do any additional setup after loading the view.
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
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
    func makeStudentAddAnswerCall(_ Choose:String) {
        let todoEndpoint: String = "https://breeze.xin/addAnswer.php?sid=\(user.id)&cid=\(courses[selectedCourse].id)&qid=\(questions[selectedQuestion].id)&Choose=\(Choose)"
        print(todoEndpoint)
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
    func makegetAnalysisCall(){
        var todoEndpoint: String = "https://breeze.xin/getAnalysis.php?tid=\(user.id)&cid=\(courses[selectedCourse].id)&qid=\(questions[selectedQuestion].id)"
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else { return }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String : Any]];
                
                for object in todo! {
                    
                    
                    outcomes.append((object["count(sid)"] as? String)!)
                }
                let str_out = "答题人数："+outcomes[0]+"正确人数:"+outcomes[1]
                let ac = UIAlertController(title: "statistics", message: str_out, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                
                outcomes.removeAll()
                
                
            } catch { return }
        }
        
        task.resume()
    
    }
    @IBAction func addAnswer(_ sender: UIButton) {
        if(user.type == "Student")
        {
        var choose: String = "A";
        
        if (chooseAnswer.selectedSegmentIndex == 1) { choose = "B"; }
        if (chooseAnswer.selectedSegmentIndex == 2) { choose = "C"; }
        if (chooseAnswer.selectedSegmentIndex == 3) { choose = "D"; }
        makeStudentAddAnswerCall(choose)
        }
        else
        {
            makegetAnalysisCall()
            
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
