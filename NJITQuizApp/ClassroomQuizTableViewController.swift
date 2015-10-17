//
//  ClassroomQuizTableViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

class ClassroomQuizTableViewController: UITableViewController {

    var question: MultipleChoiceQuestion? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var socketConnection: SocketClient!
    var timerLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socketConnection.questionCallback = { (question) in
            self.question = question
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.socketConnection.disconnect()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            return
        case 1:
            print(self.question?.answers[indexPath.row
            ])
        default:
            return
        }
    }
    
    func updateTimer() {
        guard let timerLabel = self.timerLabel, endDate = self.question?.dueTime else {
            return;
        }
        
        let interval = Int(endDate.timeIntervalSinceDate(NSDate()))
        if interval > 0 {
            timerLabel.text = "\(interval)"
        } else {
            timerLabel.text = ""
            self.question = nil
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.question != nil {
            return 2
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.question != nil {
            switch section {
            case 0:
                return 1
            case 1:
                return (self.question?.answers.count)!
            default:
                return 0
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell") as! QuestionTableViewCell
            cell.questionLabel.text = self.question?.prompt
            self.timerLabel = cell.timeLeftLabel
            cell.userInteractionEnabled = false
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell") as! AnswerTableViewCell
            let answer = self.question?.answers[indexPath.row]
            cell.answerLabel.text = answer?.text
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell") as! AnswerTableViewCell
            cell.answerLabel.text = ""
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
