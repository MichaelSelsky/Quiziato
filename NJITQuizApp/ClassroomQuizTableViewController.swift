//
//  ClassroomQuizTableViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ClassroomQuizTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var className: String?
    var instructorName: String?

    var question: MultipleChoiceQuestion? {
        didSet {
            self.tableView.reloadData()
            self.tableView.userInteractionEnabled = true
        }
    }
    
    var socketConnection: SocketClient!
    var timerLabel: UILabel?
    var canSendAnswer: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.socketConnection.questionCallback = { (question) in
            self.question = question
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        NSNotificationCenter.defaultCenter().addObserverForName("attendanceEvent", object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
        
            let userInfo = note.object! as! [String: Wrapper<Course>]
            let courseWrapper = userInfo["Course"]
            let course = courseWrapper!.wrappedValue
            self.className = course.name
            
            let instructor = course.instructor
            self.instructorName = instructor.name
            
            self.tableView.reloadData()
        }
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.socketConnection.disconnect()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.canSendAnswer {
            return
        }
        switch indexPath.section {
        case 0:
            return
        case 1:
            if let question = self.question {
                let alertController = UIAlertController(title: "Are you sure?", message: "Is \"\(question.answers[indexPath.row].text)\" your final answer?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) -> Void in
                    self.socketConnection.sendAnswer(question.answers[indexPath.row], question: question)
                    QL2Info("Sending answer \(question.answers[indexPath.row].text) for question \(question.prompt)")
                    self.tableView.userInteractionEnabled = false
                }))
                
                alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
                    self.tableView.selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.None)
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
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
    
    // MARK: - Empty Data Set
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "PencilIcon")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: self.className ?? "")
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: self.instructorName ?? "")
    }

    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.cumulative = true
        animation.repeatCount = MAXFLOAT
        
        return animation
    }
}
