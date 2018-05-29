//
//  QuestionTableViewController.swift
//  CCCS
//
//  Created by 浦清风 on 5/16/18.
//  Copyright © 2018 Alfred Liu. All rights reserved.
//

import UIKit

class Question{
    var id : Int = 0
    var content : String = ""
    var Achoice : String = ""
    var Bchoice : String = ""
    var Cchoice : String = ""
    var Dchoice : String = ""
    var correct : String = ""
}
var questions = [Question]()


class QuestionTableViewController: UITableViewController {

    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var questionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        questions.removeAll()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(user.type == "Student")
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        makeGetQuestionCall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeGetQuestionCall() {
        var loadedQuestions = [Question]()
        var todoEndpoint: String = "https://breeze.xin/getQuestion.php"
        if (user.type == "Student") {
            todoEndpoint = todoEndpoint + "?sid=\(user.id)&cid=\(courses[selectedCourse].id)"
        } else {
            todoEndpoint = todoEndpoint + "?tid=\(user.id)&cid=\(courses[selectedCourse].id)"
        }
        print(todoEndpoint)
        let url = URL(string: todoEndpoint)
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let responseData = data else { return }
            do {
                let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String : Any]];
                
                for object in todo! {
                    
                    let question : Question = Question()
                    question.id = Int((object["qid"] as? String)!)!
                    
                    question.content = (object["questext"] as? String)!
                    question.Achoice = (object["Achoice"] as? String)!
                    question.Bchoice = (object["Bchoice"] as? String)!
                    question.Cchoice = (object["Cchoice"] as? String)!
                    question.Dchoice = (object["Dchoice"] as? String)!
                    question.correct = (object["correct"] as? String)!
                    
                    loadedQuestions.append(question)
                    
                }
                print(loadedQuestions.count)
                questions = loadedQuestions
                loadedQuestions.removeAll()
                DispatchQueue.main.async { [unowned self] in
                    self.questionTableView.reloadData()
                }
            } catch { return }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(questions.count)
        return questions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section < questions.count) {
            return String(questions[section].id)
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionReuseIdentifier", for: indexPath)
        if (indexPath.section >= questions.count) { return cell }
        cell.accessoryType = .none
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Description:"
            cell.detailTextLabel?.text = questions[indexPath.section].content
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Options:"
            cell.detailTextLabel?.text = "more"
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 1) {
            selectedQuestion = indexPath.section
            self.performSegue(withIdentifier: "segueToQuestionDetail", sender: self)
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            selectedquestion = indexPath.section
            self.performSegue(withIdentifier: "segueToCourseDetail", sender: self)
        }
    }
    */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
