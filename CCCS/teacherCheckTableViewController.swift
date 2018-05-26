//
//  teacherCheckTableViewController.swift
//  CCCS
//
//  Created by Neptune Steven on 2018/5/11.
//  Copyright © 2018年 Alfred Liu. All rights reserved.
//

import UIKit

func makeGetReason(){
    atests.removeAll()
   
    var todoEndpoint: String = "https://breeze.xin/getinfo.php?"
    if(user.type=="Student"){
        todoEndpoint = todoEndpoint + "sid=\(user.id)"+"&cid=\(courses[selectedCourse].id)"
    }else{
        todoEndpoint = todoEndpoint + "cid=\(courses[selectedCourse].id)"
    }
   
    let url = URL(string: todoEndpoint)
    let urlRequest = URLRequest(url: url!)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: urlRequest) { (data, response, error) in
        guard let responseData = data else { return }
        do {
            let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String : Any]];
            for object in todo! {
               let ttemp=tempTable()
                ttemp.cid=Int((object["cid"] as? String)!)!
                ttemp.sid=Int((object["sid"] as? String)!)!
                ttemp.tempState=(object["state"]as? String)!
                ttemp.reasonForReq=(object["reason"] as? String)!
                atests.append(ttemp)
                 print ("the num of atests:\(atests.count)\n")
            }
        } catch { return }
    }
    task.resume()
   
}



class teacherCheckTableViewController: UITableViewController {

    @IBOutlet var reasonTable: UITableView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reasonTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return atests.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  String( atests[section].sid)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "zheshizz", for: indexPath)
        if (indexPath.row == 0) {
            cell.textLabel?.text = "StudentID:"
            cell.detailTextLabel?.text = String( atests[indexPath.section].sid)
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Reason:"
            cell.detailTextLabel?.text = atests[indexPath.section].reasonForReq
        } else if (indexPath.row == 2)&&(user.type=="Teacher")&&(atests[indexPath.section].tempState=="notAllowed") {
            cell.textLabel?.text = "To Check the Requestion"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
        }else if (indexPath.row == 2){
            cell.textLabel?.text="State:"
            cell.detailTextLabel?.text=atests[indexPath.section].tempState
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2)&&(user.type=="Teacher")&&(atests[indexPath.section].tempState=="notAllowed") {
            let alter=UIAlertController(title: "Allow this Request?", message: "", preferredStyle: .alert)
            let allowedAction=UIAlertAction(title: "Allow", style: .default, handler: {
                (alter)->Void in
                self.teacherAllowde(changeTable: atests[indexPath.section])
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_)in})
            
            alter.addAction(cancelAction)
            alter.addAction(allowedAction)
            present(alter, animated: true)
        }
    }

    func showAlert(_ title : String, _ msg : String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in }))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }

func teacherAllowde(changeTable :tempTable) {
    //To change in server
    let todoEndpoint: String = "https://breeze.xin/teacherPermit.php?tid=\(user.id)&sid=\(changeTable.sid)&cid=\(courses[selectedCourse].id)&password=\(user.password)"
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
                    //self.mainButton.setTitle("Stop", for: .normal)
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
}
}
