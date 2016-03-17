//
//  ReorderTableView.swift
//  DragAndDropTableViewCell1
//
//  Created by Ethan Neff on 2/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

// TODO: fix minor memory leak

import UIKit

protocol ReorderTableViewDelegate: class {
  func reorderBefore(fromIndexPath: NSIndexPath)
  func reorderAfter(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
}

extension UITableViewController: ReorderTableViewDelegate {
  func reorderBefore(fromIndexPath: NSIndexPath) {}
  func reorderAfter(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {}
}

class ReorderTableView: UITableView {
  // MARK: - PROPERTIES
  // constants
  let kReorderLiftAnimation: Double = 0.35
  let kReorderScrollMultiplier: CGFloat = 10.0
  let kReorderScrollTableViewPadding: CGFloat = 50.0
  
  // public
  var reorderInitalIndexPath: NSIndexPath?
  weak var reorderDelegate: ReorderTableViewDelegate?
  
  // private
  private var reorderGesture: UILongPressGestureRecognizer?
  private var reorderPreviousIndexPath: NSIndexPath?
  private var reorderSnapshot: UIView?
  private var reorderScrollRate: CGFloat = 0
  private var reorderGesturePressed: Bool = false
  private var reorderScrollLink: CADisplayLink?
  
  
  
  // MARK: - DELEGATION
  internal enum ReorderDelegateNotifications {
    case Before
    case After
  }
  
  private func reorderNotifyDelegate(notification notification: ReorderDelegateNotifications, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath?) {
    // notify the parent controller
    switch notification {
    case .Before: reorderDelegate?.reorderBefore(fromIndexPath)
    case .After: reorderDelegate?.reorderAfter(fromIndexPath, toIndexPath: toIndexPath!)
    }
  }
  
  
  
  // MARK: - INIT
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    initalizer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initalizer()
  }
  
  convenience init(tableView: UITableView) {
    self.init(frame: CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height), style: .Plain)
  }
  
  func initalizer() {
    reorderGesture = UILongPressGestureRecognizer(target: self, action: "reorderGestureRecognized:")
    if let reorderGesture = reorderGesture {
      reorderGesture.minimumPressDuration = 0.3
      addGestureRecognizer(reorderGesture)
    }
    
    registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  
  
  // MARK: - DEALLOC
  private func reorderDealloc() {
    reorderScrollRate = 0
    if let scrollLink = reorderScrollLink {
      scrollLink.invalidate()
    }
    if let reorderSnapshot = reorderSnapshot {
      reorderSnapshot.removeFromSuperview()
    }
    print(reorderSnapshot)

    reorderInitalIndexPath = nil
    reorderPreviousIndexPath = nil
    reorderSnapshot = nil
  }
  
  
  
  // MARK: - GESTURE
  func reorderGestureRecognized(gesture: UILongPressGestureRecognizer) {
    // long press on cell
    let location = gesture.locationInView(self)
    
    switch gesture.state {
    case UIGestureRecognizerState.Began:
      // began
      if let indexPath = indexPathForRowAtPoint(location) {
        reorderGesturePressed = true
        reorderLoopToDetectScrolling()
        reorderNotifyDelegate(notification: .Before, fromIndexPath: indexPath, toIndexPath: nil)
        reorderHandleDelegateIndexChange(location: location)
        if let previousIndexPath = reorderPreviousIndexPath, let cell = cellForRowAtIndexPath(previousIndexPath) {
          reorderCreateSnapshotCell(cell: cell)
          reorderLiftSnapshotCell(location: location, cell: cell)
        }
      }
    case UIGestureRecognizerState.Changed:
      // changed
      reorderUpdateScrollRateForTableViewScrolling(location: location)
    default:
      // ended
      if let initialIndexPath = reorderInitalIndexPath, let previousIndexPath = reorderPreviousIndexPath, let cell = cellForRowAtIndexPath(previousIndexPath) {
        reorderGesturePressed = false
        reorderDropSnapshotCell(cell: cell) { finished in
          self.reorderNotifyDelegate(notification: .After, fromIndexPath: initialIndexPath, toIndexPath: previousIndexPath)
          self.reorderDealloc()
        }
      }
    }
  }
  
  
  // MARK: - BEGIN
  private func reorderLoopToDetectScrolling() {
    // start looping for scrolling (because want to scroll when non-moving near edges [UIGestureRecognizerState.Change won't be called])
    
    reorderScrollLink = CADisplayLink(target: self, selector: "reorderScrollTableWithCell")
    reorderScrollLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  private func reorderHandleDelegateIndexChange(location location: CGPoint) {
    // handle out of bounds limit of tableview
    let delegateTouchIndexPath = indexPathForRowAtPoint(location) ?? NSIndexPath(forRow: numberOfRowsInSection(0)-1, inSection: 0)
    
    // save initial and previous indexes (used the passed index [reorderInitalIndexPath] if available)
    reorderInitalIndexPath = reorderInitalIndexPath ?? delegateTouchIndexPath
    reorderPreviousIndexPath = delegateTouchIndexPath
    print(reorderInitalIndexPath,reorderPreviousIndexPath)
    
    if let initalIndexPath = reorderInitalIndexPath, let previousIndexPath = reorderPreviousIndexPath {
      // reorder any changes from the delegate
      moveRowAtIndexPath(initalIndexPath, toIndexPath: previousIndexPath)
    }
  }
  
  private func reorderCreateSnapshotCell(cell cell: UITableViewCell) {
    // create snapshot cell (the pickup cell)
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
    cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
    UIGraphicsEndImageContext()
    reorderSnapshot = UIImageView(image: image)
    if let reorderSnapshot = reorderSnapshot {
      reorderSnapshot.layer.masksToBounds = false
      reorderSnapshot.layer.cornerRadius = 0.0
      reorderSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
      reorderSnapshot.layer.shadowRadius = 3.0
      reorderSnapshot.layer.shadowOpacity = 0.4
      reorderSnapshot.center = cell.center
      reorderSnapshot.alpha = 0.0
      addSubview(reorderSnapshot)
    }
  }
  
  private func reorderLiftSnapshotCell(location location: CGPoint, cell: UITableViewCell) {
    // animate the snapshot lift
    UIView.animateWithDuration(kReorderLiftAnimation, animations: {
      cell.center.y = location.y
      cell.alpha = 0.0
      if let reorderSnapshot = self.reorderSnapshot {
        reorderSnapshot.center = cell.center
        reorderSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
        reorderSnapshot.alpha = 0.8
      }
      }, completion: { (finished) -> Void in
        if finished {
          cell.hidden = true
        }
    })
  }
  
  
  
  // MARK: - CHANGED
  private func reorderCorrectDraggingBounds(location location: CGPoint) {
    // update position of the drag view so it wont go past the top or the bottom too far
    if let reorderSnapshot = reorderSnapshot where location.y >= 0 && location.y <= contentSize.height + kReorderScrollTableViewPadding {
      reorderSnapshot.center = CGPointMake(center.x, location.y)
    }
  }
  
  private func reorderUpdateScrollRateForTableViewScrolling(location location: CGPoint) {
    // adjust rect for content inset as we will use it below for calculating scroll zones
    var rect: CGRect = bounds
    rect.size.height -= contentInset.top
    
    // use scrollLink loop to move tableView and snapshot by changing the reorderScrollRate property
    let scrollZoneHeight: CGFloat = rect.size.height / 6
    let bottomScrollBeginning: CGFloat = contentOffset.y + contentInset.top + rect.size.height - scrollZoneHeight
    let topScrollBeginning: CGFloat = contentOffset.y + contentInset.top + scrollZoneHeight
    
    // reorderScrollRate updates reorderScrollTableWithCell() via the reorderScrollLink
    if location.y >= bottomScrollBeginning {
      // bottom
      reorderScrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight
    } else if location.y <= topScrollBeginning {
      // top
      reorderScrollRate = (location.y - topScrollBeginning) / scrollZoneHeight
    } else {
      // middle
      reorderScrollRate = 0
    }
  }
  
  func reorderScrollTableWithCell() {
    // looping via the CADisplayLink of reorderScrollLink to detect whether to move the tableview or not
    if let gesture: UILongPressGestureRecognizer = reorderGesture where reorderGesturePressed {
      let location: CGPoint = gesture.locationInView(self)
      let prevOffset: CGPoint = contentOffset
      let nextOffset: CGPoint = CGPointMake(prevOffset.x, prevOffset.y + reorderScrollRate * kReorderScrollMultiplier)
      
      reorderScrollWithTableView(prevOffset: prevOffset, nextOffset: nextOffset)
      reorderCorrectDraggingBounds(location: location)
      reorderUpdateCurrentLocation(gesture: gesture, location: location)
    }
  }
  
  private func reorderScrollWithTableView(prevOffset prevOffset: CGPoint, var nextOffset: CGPoint ) {
    // scroll the tableview on drag
    if nextOffset.y < -contentInset.top {
      nextOffset.y = -contentInset.top
    }
    else if contentSize.height + contentInset.bottom < frame.size.height {
      nextOffset = prevOffset
    }
    else if nextOffset.y > (contentSize.height + contentInset.bottom) - frame.size.height {
      nextOffset.y = (contentSize.height + contentInset.bottom) - frame.size.height
    }
    contentOffset = nextOffset
  }

  private func reorderUpdateCurrentLocation(gesture gesture: UILongPressGestureRecognizer, location: CGPoint ) {
    // reorder the tableview cells on drag
    if let nextIndexPath = indexPathForRowAtPoint(location), let prevIndexPath = reorderPreviousIndexPath {
      if nextIndexPath != prevIndexPath {
        moveRowAtIndexPath(prevIndexPath, toIndexPath: nextIndexPath)
        reorderPreviousIndexPath = nextIndexPath
      }
    }
  }
  
  
  
  // MARK: - ENDED
  private func reorderDropSnapshotCell(cell cell: UITableViewCell, completion: (finished: Bool) -> ()) {
    cell.hidden = false
    cell.alpha = 0.0
    UIView.animateWithDuration(kReorderLiftAnimation, animations: {
      cell.alpha = 1.0
      if let reorderSnapshot = self.reorderSnapshot {
        reorderSnapshot.center = cell.center
        reorderSnapshot.transform = CGAffineTransformIdentity
        reorderSnapshot.alpha = 0.0
      }
      }, completion: { (finished) -> Void in
        cell.hidden = false
        completion(finished: finished)
    })
  }
}