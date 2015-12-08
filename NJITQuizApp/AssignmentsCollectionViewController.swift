 //
//  AssignmentsCollectionViewController.swift
//  iClicker2000™
//
//  Created by MichaelSelsky on 11/23/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AssignmentsCollectionViewController: UICollectionViewController {
    
    var assignments: [Assignment] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = UIColor.lightGrayColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assignments.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("assignmentCell", forIndexPath: indexPath) as! AssignmentCollectionViewCell
        
        let assignment = self.assignments[indexPath.item]
        
        cell.promptLabel.text = assignment.question.prompt
        if let submittedAns = assignment.submittedAns {
            let ansText = assignment.question.answers.filter({ (mcAns) -> Bool in
                mcAns.answerID == submittedAns
            }).first
            cell.yourAnswerLabel.text = "You answered: \(ansText?.text)"
        } else {
            cell.yourAnswerLabel.text = nil
        }
        
        if let correctAns = assignment.correctAns {
            let ansText = assignment.question.answers.filter({ (mcAns) -> Bool in
                mcAns.answerID == correctAns
            }).first
            cell.correctAnswerLabel.text = "The correct answer was: \(ansText?.text)"
        } else {
            cell.yourAnswerLabel.text = nil
        }
        
        cell.backgroundColor = UIColor.whiteColor()
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
