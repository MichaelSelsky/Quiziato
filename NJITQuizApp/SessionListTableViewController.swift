//
//  SessionListTableViewController.swift
//  iClicker2000™
//
//  Created by MichaelSelsky on 11/23/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import Moya
import Argo

class SessionListTableViewController: UITableViewController {
    
    var apiProvider: MoyaProvider<API>!
    var gradedSessions: [GradedSession] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.apiProvider.request(.GetCourses) { (data, statusCode, response, error) -> () in
            QL1Debug(data)
            guard error == nil else {
                QL4Error("Status Code \(error!)")
                return
            }
            guard statusCode == 200 else {
                QL3Warning(statusCode)
                return
            }
            guard let d = data else {
                QL4Error("No Data")
                return
            }
            var json: AnyObject?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(d, options: .MutableLeaves)
            } catch {
                QL4Error(error)
            }
            guard let j = json else {
                QL4Error("JSON not parsable")
                return
            }
            let optionalSessions: [Session]? = decode(j)
            guard let sessions = optionalSessions else {
                QL3Warning("Argo failed")
                return
            }
            for s in sessions {
                self.apiProvider.request(.GetGradesForSession(s.id)){ (data, statusCode, response, error) -> () in
                    guard error == nil else {
                        QL4Error("Status Code \(error!)")
                        return
                    }
                    guard statusCode == 200 else {
                        QL3Warning(statusCode)
                        return
                    }
                    guard let d = data else {
                        QL4Error("No Data")
                        return
                    }
                    var json: AnyObject?
                    do {
                        json = try NSJSONSerialization.JSONObjectWithData(d, options: .MutableLeaves) as? [[String: AnyObject]]
                    } catch {
                        QL4Error(error)
                    }
                    guard let gradeJSON = json as? [[String: AnyObject]] else {
                        QL4Error("JSON not parsable")
                        return
                    }
                    
                    let test = gradeJSON.first
                    
                    print(test?["assignment"]!["question"])
                    
                    let assignments: [Assignment]? = decode(gradeJSON)

                    guard let assign = assignments else {
                        QL4Error("Argo error")
                        return
                    }
                    
                    let gradedAnswers = assign.filter({ (assignment) -> Bool in
                        return assignment.graded
                    })
                    
                    let correctAnswers = gradedAnswers.filter({ (assignment) -> Bool in
                        return assignment.correct
                    })
                    
                    let grade = Double(correctAnswers.count) / Double(gradedAnswers.count)
                    
                    let gradedSession = (s, grade, assignments)
                    
                    var gSessions = self.gradedSessions
                    gSessions.append(gradedSession)
                    self.gradedSessions = gSessions.sort({$0.0.date > $1.0.date})
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gradedSessions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        let grade = self.gradedSessions[indexPath.row].1
        
        cell.textLabel?.text = "\(self.gradedSessions[indexPath.row].0.course.name) - \(self.gradedSessions[indexPath.row].0.date)"
        cell.detailTextLabel?.text = "\(100 * grade)"
        
        let redColor = CGFloat(1.0 - grade)
        let greenColor = CGFloat(grade)
        let cellColor = UIColor(red: redColor, green: greenColor, blue: 0, alpha: 1)
        
        cell.backgroundColor = cellColor
        
        return cell
    }

    @IBAction func dismissButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSessionDetailSegue" {
            let navVc = segue.destinationViewController as! UINavigationController
            let detailVC = navVc.viewControllers.first as! AssignmentsCollectionViewController
            let senderCell = sender as? UITableViewCell
            if let senderCell = senderCell {
                let index = self.tableView.indexPathForCell(senderCell)
                detailVC.assignments = self.gradedSessions[(index?.row)!].2!
            }
        }
    }
}
