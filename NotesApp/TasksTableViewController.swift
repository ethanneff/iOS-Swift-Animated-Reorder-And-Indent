//
//  TasksTableViewController.swift
//  NotesApp
//
//  Created by Ethan Neff on 4/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
  // MARK: - PROPERTIES
  var viewData: [Task] = []
  var realData: [Task] = []
  var gestureDoubleTap: UITapGestureRecognizer?
  var gestureSingleTap: UITapGestureRecognizer?



  // MARK: - INIT
  override func viewDidLoad() {
    super.viewDidLoad()
    initTableView()
    initDoubleTap()
    initSingleTap()
    initTableViewData()
  }

  // MARK: - DEINIT
  private func dealloc() {
    deallocDoubleTap()
    deallocSingleTap()
  }

  private func initTableView() {
    // already set in IB
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderDelegate = self
    }
  }

  private func initTableViewData() {
    // TODO: load and save
    realData = Task.loadTestData()
    viewData = realData
  }



  // MARK: - ERRORS
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }



  // MARK: - TABLEVIEW DATASOURCE
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewData.count
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return TasksTableViewCell.height
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // already set in IB
    let cell = tableView.dequeueReusableCellWithIdentifier(TasksTableViewCell.identifier, forIndexPath: indexPath) as! TasksTableViewCell
    let data = viewData[indexPath.row]
    cell.renderData(data: data)
    gestureRecognizedSwipe(cell: cell)

    return cell
  }



  // MARK: - TABLEVIEW MODIFICATION
  func tableViewRemoveRow(indexPath indexPath: NSIndexPath) {
    tableView.beginUpdates()
    viewData.removeAtIndex(indexPath.row)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    tableView.endUpdates()
  }

  func tableViewInsertRow(indexPath indexPath: NSIndexPath, data: Task) {
    tableView.beginUpdates()
    viewData.insert(data, atIndex: indexPath.row)
    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    tableView.endUpdates()
  }

  func tableViewReloadRow(indexPath indexPath: NSIndexPath) {
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    tableView.endUpdates()
  }

  func tableViewReloadData() {
    viewData = realData
    tableView.reloadData()
  }




  // MARK: - GESTURES

  private func gestureRecognizedSwipe(cell cell: SwipeCell) {
    cell.defaultColor = Global.colorBorder
    cell.swipeDelegate = self
    cell.firstTrigger = 0.15
    cell.secondTrigger = 0.40
    cell.thirdTrigger = 0.65

    // complete
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: Global.colorButton) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.toggleComplete(indexPath: indexPath, complete: true)
      }
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: Global.colorSubtitle) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.toggleComplete(indexPath: indexPath, complete: false)
      }
    }

    // indent
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left2, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: Global.colorBrown) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.indentSection(indexPath: indexPath, increase: true)
      }
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right2, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: Global.colorBrown) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.indentSection(indexPath: indexPath, increase: false)
      }
    }

    // trash
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right3, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: Global.colorRed) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.toggleRemove(indexPath: indexPath)
      }
    }

    // notification
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left3, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "clock")), color: Global.colorYellow) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.toggleNotification(indexPath: indexPath)
      }
    }
  }



  // MARK: - GESTURES
  private func initDoubleTap() {
    gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap!.numberOfTapsRequired = 2
    gestureDoubleTap!.numberOfTouchesRequired = 1
    tableView.addGestureRecognizer(gestureDoubleTap!)
  }

  private func initSingleTap() {
    gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap!.numberOfTapsRequired = 1
    gestureSingleTap!.numberOfTouchesRequired = 1
    gestureSingleTap!.requireGestureRecognizerToFail(gestureDoubleTap!)
    tableView.addGestureRecognizer(gestureSingleTap!)
  }

  private func deallocDoubleTap() {
    if let doubleTap = gestureDoubleTap {
      tableView.removeGestureRecognizer(doubleTap)
    }
  }
  private func deallocSingleTap() {
    if let singleTap = gestureSingleTap {
      tableView.removeGestureRecognizer(singleTap)
    }
  }

  internal func gestureRecognizedDoubleTap(sender: UITapGestureRecognizer) {
    print("doubleTap")
    Util.playSound(systemSound: .Tap)
    let location = sender.locationInView(tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      toggleCollapse(indexPath: indexPath)
    }
  }


  internal func gestureRecognizedSingleTap(sender: UITapGestureRecognizer) {
    print("single tap")
    // TODO: search titles and bodies
    // TODO: search tags
    // TODO: add tag
    // TODO: remove tag

  }



  // MARK: - BUTTONS
  @IBAction func rightNavPressed(sender: UIBarButtonItem) {
    Util.playSound(systemSound: .Tap)
    // add to top
    print(viewData)
    print(realData)

    // TODO: collpase all
    // TODO: expand all
    // TODO: clear completed
    // TODO: clear notifications
    // TODO: view notifications
    // TODO: sound toggle
    // TODO: change title     navigationItem.title = "AODINA"
  }

  @IBAction func leftNavPressed(sender: UIBarButtonItem) {
    Util.playSound(systemSound: .Tap)
  }

  @IBAction func cellAccessoryPressed(sender: UIButton) {
    Util.playSound(systemSound: .Tap)
    let location = sender.convertPoint(CGPointZero, toView: tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      let item = viewData[indexPath.row]
      if item.collapsed {
        toggleCollapse(indexPath: indexPath)
      } else {
        toggleInsert(indexPath: indexPath)
      }
    }
  }


  // MARK: - COLLAPSE
  private func toggleCollapse(indexPath indexPath: NSIndexPath) {
    let collapsed = viewData[indexPath.row].collapsed
    if collapsed {
      expandSection(indexPath: indexPath)
    } else {
      collapseSection(indexPath: indexPath)
    }
  }

  private func expandSection(indexPath indexPath: NSIndexPath) {
    let parent = viewData[indexPath.row]
    let childIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)

    // parent
    parent.collapsed = false
    parent.children = 0
    tableViewReloadRow(indexPath: indexPath)

    // children
    var children: [Task] = []
    var parentFound = false
    for i in 0..<realData.count {
      // real items since already removed
      let child = realData[i]
      if child === parent {
        parentFound = true
        continue
      }

      if parentFound {
        if child.indent <= parent.indent {
          break
        }
        child.children = 0
        child.collapsed = parent.collapsed
        children.insert(child, atIndex: 0)
      }
    }

    // insert backwards
    for child in children {
      tableViewInsertRow(indexPath: childIndexPath, data: child)
    }
  }

  private func collapseSection(indexPath indexPath: NSIndexPath) {
    let viewItems = viewData
    let parent = viewData[indexPath.row]
    let childIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
    let child = childIndexPath.row > viewData.count-1 ? viewData[viewData.count-1] : viewData[childIndexPath.row]

    // only collpase if parent has a child
    var children = 0
    if child.indent > parent.indent {
      // children
      for i in childIndexPath.row..<viewItems.count {
        let child = viewItems[i]
        if child.indent <= parent.indent {
          break
        }
        children += child.children + 1
        child.collapsed = true
        // remove forwards
        tableViewRemoveRow(indexPath: childIndexPath)
      }
    }

    // parent
    parent.collapsed = true
    parent.children = children
    tableViewReloadRow(indexPath: indexPath)
  }



  // MARK: - INDENT
  private func indentSection(indexPath indexPath: NSIndexPath, increase: Bool) {
    let parent = viewData[indexPath.row]

    // children
    if parent.collapsed {
      var parentFound = false
      for i in 0..<realData.count {
        let child = realData[i]
        if child === parent {
          parentFound = true
          continue
        }

        if parentFound {
          if child.indent <= parent.indent {
            break
          }
          child.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
        }
      }
    }

    // parent
    parent.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
    tableViewReloadRow(indexPath: indexPath)

    // sound
    Util.playSound(systemSound: .SMSSent)
  }



  // MARK: - REORDER
  override func reorderBeforeLift(fromIndexPath: NSIndexPath) {
    // collapse
    collapseSection(indexPath: fromIndexPath)
  }
  override func reorderAfterLift(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    // update controller data for collapseSection
    let direction = fromIndexPath.row > toIndexPath.row ? 1 : 0
    viewData.insert(viewData[fromIndexPath.row], atIndex: toIndexPath.row)
    viewData.removeAtIndex(fromIndexPath.row+direction)
  }

  override func reorderDuringMove(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    // needed to prevent re-appearing of lifted cell after tableview scrolls out of focus
    swap(&viewData[fromIndexPath.row], &viewData[toIndexPath.row])
  }

  override func reorderAfterDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    // expand and update controller data
    expandSection(indexPath: toIndexPath)
    updateDataOrder(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath)
  }

  private func updateDataOrder(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    let parent = realData[fromIndexPath.row]
    var section = [Task]()

    // parent
    section.append(parent)
    realData.removeAtIndex(fromIndexPath.row)

    // children
    while true {
      if fromIndexPath.row >= realData.count {
        break
      }
      let child = realData[fromIndexPath.row]
      if child.indent <= parent.indent {
        break
      }
      section.append(child)
      realData.removeAtIndex(fromIndexPath.row)
    }

    // move to
    for each in section.reverse() {
      realData.insert(each, atIndex: toIndexPath.row)
    }
  }

  // MARK: - COMPLETED
  private func toggleComplete(indexPath indexPath: NSIndexPath, complete: Bool) {
    let parent = viewData[indexPath.row]

    // TODO: copied from indent
    if parent.collapsed {
      // children
      if parent.collapsed {
        var parentFound = false
        for i in 0..<realData.count {
          let child = realData[i]
          if child === parent {
            parentFound = true
            continue
          }

          if parentFound {
            if child.indent <= parent.indent {
              break
            }
            child.completed = complete
          }
        }
      }
    }

    // find new path for parent
    // remove parent and children (real and view)
    // insert parent and children (real and view)


    // parent
    parent.completed = complete
    tableViewReloadRow(indexPath: indexPath)

    // sound
    Util.playSound(systemSound: .MailSent)
  }

  // MARK: - NOTIFICATION
  private func toggleNotification(indexPath indexPath: NSIndexPath) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let today = UIAlertAction(title: "Later Today", style: .Default, handler: { (action) in
    })
    let tomorrow = UIAlertAction(title: "This Evening", style: .Default, handler: { (action) in
    })
    let weekend = UIAlertAction(title: "This Weekend", style: .Default, handler: { (action) in
    })
    let week = UIAlertAction(title: "Next Week", style: .Default, handler: { (action) in
    })
    let month = UIAlertAction(title: "In a Month", style: .Default, handler: { (action) in
    })
    let someday = UIAlertAction(title: "Someday", style: .Default, handler: { (action) in
    })
    let pick = UIAlertAction(title: "Pick Date", style: .Default, handler: { (action) in
    })
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })

    alert.addAction(today)
    alert.addAction(tomorrow)
    alert.addAction(weekend)
    alert.addAction(week)
    alert.addAction(month)
    alert.addAction(someday)
    alert.addAction(pick)
    alert.addAction(cancel)

    week.setValue(UIImage(named: "check"), forKey: "image")
    presentViewController(alert, animated: true, completion:nil)
  }


  // MARK: - ADD
  private func toggleInsert(indexPath indexPath: NSIndexPath) {
    print("insert",indexPath.row+1)

  }

  // MARK: - REMOVE
  private func toggleRemove(indexPath indexPath: NSIndexPath) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let delete = UIAlertAction(title: "Delete", style: .Default, handler: { (action) in
      self.removeSection(indexPath: indexPath)
    })
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alert.addAction(delete)
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion:nil)
  }

  private func removeSection(indexPath indexPath: NSIndexPath) {
    // TODO: better version of INDENT

    // search children
    let parent = viewData[indexPath.row]
    if parent.collapsed {
      // find parent index
      var realParentIndex = 0
      for i in 0..<realData.count {
        let child = realData[i]
        if child === parent {
          realParentIndex = i
          break
        }
      }
      let realParent = realData[realParentIndex]

      // remove children from real
      while true {
        if realParentIndex+1 >= realData.count {
          break
        }

        let realChild = realData[realParentIndex+1]
        if realChild.indent <= realParent.indent {
          break
        }
        realData.removeAtIndex(realParentIndex+1)
      }
    }

    // remove parent from real and view
    realData.removeAtIndex(indexPath.row)
    tableViewRemoveRow(indexPath: indexPath)
  }


  // MARK: - EDIT

  // MARK: - REFRESH
}