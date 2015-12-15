 //
//  AssignmentsCollectionViewController.swift
//  iClicker2000™
//
//  Created by MichaelSelsky on 11/23/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
 

class AssignmentsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var assignments: [Assignment] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
            if let ans = ansText {
                cell.yourAnswerLabel.text = "You answered: \(ans.text)"
            } else {
                cell.yourAnswerLabel.text = nil
            }
        } else {
            cell.yourAnswerLabel.text = nil
        }
        
        if let correctAns = assignment.correctAns {
            let ansText = assignment.question.answers.filter({ (mcAns) -> Bool in
                mcAns.answerID == correctAns
            }).first
            if let ans = ansText {
                cell.correctAnswerLabel.text = "The correct answer was: \(ans.text)"
            } else {
                cell.correctAnswerLabel = nil
            }
        } else {
            cell.correctAnswerLabel.text = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height: CGFloat = 100.0
        return CGSize(width: collectionView.bounds.size.width - 8, height: height)
    }

}
