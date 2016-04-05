//
//  TableViewController2.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 3/29/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TableViewController2: UITableViewController {
  // MARK: - PROPERTIES
  var viewData = [TableViewControllerData]()
  var realData = [TableViewControllerData]()
  var gestureDoubleTap: UITapGestureRecognizer?
  
  // MARK: - LOAD
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initReorderTableView()
    initSwipeCellXib()
    initDefaultTableViewLayout()
    initGestureDoubleTapToCollapse()
    initTestData()
  }
  
  // MARK: - UNLOAD
  private func dealloc() {
    if let doubleTap = gestureDoubleTap {
      tableView.removeGestureRecognizer(doubleTap)
    }
  }
  
  @IBAction func left(sender: AnyObject) {
    viewData.removeAll()
    realData.removeAll()
    initTestData()
    tableView.reloadData()
  }
  
  @IBAction func right(sender: AnyObject) {
    print(viewData)
    print(realData)
  }
  
  
  // MARK: - TABLEVIEW
  private func initTestData() {
    viewData = TableViewControllerData.loadTestData()
    realData = viewData
  }
  
  private func initReorderTableView() {
    tableView = ReorderTableView(tableView: tableView)
    tableView.delegate = self
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderDelegate = self
    }
  }
  
  private func initSwipeCellXib() {
    let nib = UINib(nibName: "SwipeCell", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    tableView.registerClass(SwipeCell.self, forCellReuseIdentifier: "cell")
  }
  
  private func initDefaultTableViewLayout() {
    // nav controller properties
    navigationController?.navigationBarHidden = false
    
    // table properties
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRectZero)
  }
  
  // MARK: - TABLEVIEW MODIFICATION
  func tableViewRemoveRow(indexPath indexPath: NSIndexPath) {
    tableView.beginUpdates()
    viewData.removeAtIndex(indexPath.row)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  func tableViewInsertRow(indexPath indexPath: NSIndexPath, data: TableViewControllerData) {
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
  private func initGestureDoubleTapToCollapse() {
    gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap!.numberOfTapsRequired = 2
    tableView.addGestureRecognizer(gestureDoubleTap!)
  }
  
  
  // MARK: - DOUBLE TAP COLLAPSE
  internal func gestureRecognizedDoubleTap(sender: UITapGestureRecognizer) {
    let location = sender.locationInView(tableView)
    toggleCollapse(location: location)
  }
  
  private func toggleCollapse(location location: CGPoint) {
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      let collapsed = viewData[indexPath.row].collapsed
      if collapsed {
        expandSection(indexPath: indexPath)
      } else {
        collapseSection(indexPath: indexPath)
      }
    }
  }
  
  private func expandSection(indexPath indexPath: NSIndexPath) {
    let viewItems = viewData
    let realItems = realData
    let parent = viewItems[indexPath.row]
    let childIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
    
    // parent
    parent.collapsed = false
    tableViewReloadRow(indexPath: indexPath)
    
    // children
    var children = [TableViewControllerData]()
    var parentFound = false
    for i in 0..<realItems.count {
      // real items since already removed
      let child = realItems[i]
      if child === parent {
        parentFound = true
        continue
      }
      
      if parentFound {
        if child.indent <= parent.indent {
          break
        }
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
    if child.indent > parent.indent {
      // parent
      parent.collapsed = true
      tableViewReloadRow(indexPath: indexPath)
      
      // children
      for i in childIndexPath.row..<viewItems.count {
        let child = viewItems[i]
        if child.indent <= parent.indent {
          break
        }
        child.collapsed = true
        // remove forwards
        tableViewRemoveRow(indexPath: childIndexPath)
      }
    }
  }
  
  
  // MARK: - SWIPE TO INDENT
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
    let originalViewCount = viewData.count-1
    expandSection(indexPath: toIndexPath)
    tableView.scrollToRowAtIndexPath(toIndexPath, atScrollPosition: .Middle, animated: true)
    if toIndexPath.row == originalViewCount {
      
    }
    realData = viewData
    print(realData)
  }
  
  //  override func reorderAfterDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  //    // move cell
  ////    let originalViewCount = viewData.count-1
  //    // issue moving only 1 cell
  //
  //    expandSection(indexPath: fromIndexPath)
  ////        print(viewData)
  ////    realData = viewData
  //    // not expanding on last row
  //    // not collapsing large groups
  ////    print(viewData)
  //
  //    //    print("expanded")
  //    //    print(viewData)
  //    //    print(realData)
  //    // search view for fromIndexPath
  //    // remove from real
  //    // uncollapse cell/group
  ////    tableViewReloadRow(indexPath: toIndexPath)
  //  }
  
  
  
  
  
  // MARK: - TABLEVIEW DATA SOURCE
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewData.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = initSwipeCell(indexPath: indexPath)
    cell = initDefaultCellLayout(cell: cell)
    cell = initCellLayout(cell: cell, indexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 30
  }
  
  
  // MARK: - TABLEVIEW CELL
  private func initSwipeCell(indexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SwipeCell
    
    cell.swipeDelegate = self
    cell.firstTrigger = 0.25
    cell.secondTrigger = 0.55
    
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left1, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .brownColor()) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.indentSection(indexPath: indexPath, increase: true)
      }
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right1, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .brownColor()) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.indentSection(indexPath: indexPath, increase: false)
      }
    }
    
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left2, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: .greenColor()) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.tableViewRemoveRow(indexPath: indexPath)
      }
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right2, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: .redColor()) { (cell) -> () in
      if let indexPath = self.tableView.indexPathForCell(cell) {
        self.tableViewRemoveRow(indexPath: indexPath)
      }
    }
    
    return cell
  }
  
  
  private func indentCell() {
    
  }
  
  private func unindentCell() {
    
  }
  
  private func collapseCell() {
    
  }
  
  private func expandCell() {
    
  }
  
  private func initDefaultCellLayout(cell cell: UITableViewCell) -> UITableViewCell {
    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    cell.selectionStyle = .None
    return cell
  }
  
  private func initCellLayout(cell cell: UITableViewCell, indexPath: NSIndexPath) -> UITableViewCell {
    // data
    let item = viewData[indexPath.row]
    
    // indent
    var indent = " "
    for _ in 0..<item.indent {
      indent += "      "
    }
    cell.textLabel?.text = indent + item.name
    
    // collapse
    cell.accessoryType = item.collapsed ? .DisclosureIndicator :.None
    
    return cell
  }
}
