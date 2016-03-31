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
  var viewData = [ViewData]()
  var realData = [ViewData]()
  var gestureDoubleTap: UITapGestureRecognizer?
  
  // MARK: - LOAD
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initReorderTableView()
    initSwipeCellXib()
    initDefaultTableViewLayout()
    initGestureDoubleTapToCollapse()
    loadTestData()
  }
  
  // MARK: - UNLOAD
  private func dealloc() {
    if let doubleTap = gestureDoubleTap {
      tableView.removeGestureRecognizer(doubleTap)
    }
  }
  
  @IBAction func left(sender: AnyObject) {
    //    tableViewReloadData()
    tableView.reloadData()
  }
  
  @IBAction func right(sender: AnyObject) {
  }
  
  
  // MARK: - TABLEVIEW
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
  func tableViewRemoveRow(indexRow indexRow: Int) {
    tableView.beginUpdates()
    viewData.removeAtIndex(indexRow)
    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  func tableViewInsertRow(item item: ViewData, indexRow: Int) {
    tableView.beginUpdates()
    viewData.insert(item, atIndex: indexRow)
    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  func tableViewReloadRow(indexRow indexRow: Int) {
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
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
      tableViewReloadRow(indexRow: indexPath.row)
    }
  }
  
  private func expandSection(indexPath indexPath: NSIndexPath) {
    let viewItems = viewData
    let realItems = realData
    let parent = viewItems[indexPath.row]
    let firstChildIndex = indexPath.row+1
    
    // parent
    parent.collapsed = !parent.collapsed
    
    // children
    var children = [ViewData]()
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
      tableViewInsertRow(item: child, indexRow: firstChildIndex)
    }
  }
  
  private func collapseSection(indexPath indexPath: NSIndexPath) {
    let viewItems = viewData
    let parent = viewItems[indexPath.row]
    let firstChildIndex = indexPath.row+1
    
    // parent
    parent.collapsed = !parent.collapsed
    //    tableViewReloadRow(indexRow: indexPath.row)
    
    // children
    for i in firstChildIndex..<viewItems.count {
      let child = viewItems[i]
      if child.indent <= parent.indent {
        break
      }
      child.collapsed = parent.collapsed
      // remove forwards
      tableViewRemoveRow(indexRow: firstChildIndex)
    }
  }
  
  
  // MARK: - SWIPE TO INDENT
  private func toggleIndent(cell cell:UITableViewCell, increase: Bool) {
    if let indexPath = tableView.indexPathForCell(cell) {
      indentSection(indexPath: indexPath, increase: increase)
    }
  }
  
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
    tableViewReloadRow(indexRow: indexPath.row)
  }
  
  
  // MARK: - REORDER
  override func reorderBefore(fromIndexPath: NSIndexPath) {
    // collapse cell/group
    // return new index
  }
  
  override func reorderAfter(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    // move cell
    // uncollapse cell/group
  }
  
  
  
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
  
  
  
  // MARK: - TABLEVIEW CELL
  private func initSwipeCell(indexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SwipeCell
    cell.swipeDelegate = self
    cell.firstTrigger = 0.25
    cell.secondTrigger = 0.55
    
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left1, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .brownColor()) { (cell) -> () in
      self.toggleIndent(cell: cell, increase: true)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right1, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .brownColor()) { (cell) -> () in
      self.toggleIndent(cell: cell, increase: false)
    }
    
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left2, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: .greenColor()) { (cell) -> () in
      self.toggleDelete(cell: cell)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right2, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: .redColor()) { (cell) -> () in
      self.toggleDelete(cell: cell)
    }
    
    return cell
  }
  
  
  private func toggleDelete(cell cell:UITableViewCell) {
    if let index = tableView.indexPathForCell(cell) {
      tableViewRemoveRow(indexRow: index.row)
    }
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
    cell.textLabel?.text = indent + item.name + " " + String(item.indent)
    
    // collapse
    cell.accessoryType = item.collapsed ? .DisclosureIndicator :.None
    
    return cell
  }
  
  
  // MARK: - DATA
  private func loadTestData() {
    viewData.removeAll()
    viewData.append(ViewData(name: "1.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "1.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "1.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "1.2.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "1.2.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "1.3.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "1.3.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "1.3.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "1.4.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "2.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "2.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "2.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "2.2.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "2.2.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "2.3.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "2.3.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "2.3.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "2.4.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "3.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "3.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "3.1.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.1.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.1.3", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "4.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "5.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "5.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "5.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "5.2.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "5.2.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "5.3.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "5.4.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "6.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "6.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "6.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "6.2.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "6.2.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "6.3.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "6.4.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "7.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "7.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "7.1.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "7.1.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "7.1.3", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "7.2.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "8.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.1", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.2", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.3", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.2.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.1", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.2", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.1.3", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.2.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "9.0.0", indent: 0, collapsed: false))
    realData = viewData
  }
}
