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
    
    //    realData = loadTestData(realData)
  }
  
  // MARK: - UNLOAD
  private func dealloc() {
    if let doubleTap = gestureDoubleTap {
      tableView.removeGestureRecognizer(doubleTap)
    }
  }
  
  @IBAction func left(sender: AnyObject) {
    tableViewReloadData()
  }
  
  @IBAction func right(sender: AnyObject) {
    
  }
  
  
  // MARK: - TABLEVIEW
  private func initReorderTableView() {
    tableView = ReorderTableView(tableView: tableView)
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderDelegate = self
    }
  }
  
  private func initSwipeCellXib() {
    let nib = UINib(nibName: "SwipeCell", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "cell")
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
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      if !viewData[indexPath.row].collapsed {
        collapseSection(index: indexPath.row)
      } else {
        expandSection(index: indexPath.row)
      }
    }
  }
  
  
  private func expandSection(index index: Int) {
    let viewItems = viewData
    let realItems = realData
    let parent = viewItems[index]
    let firstChild = index+1
    
    // parent
    parent.collapsed = !parent.collapsed
    tableViewReloadRow(indexRow: index)
    
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
      tableViewInsertRow(item: child, indexRow: firstChild)
    }
  }
  
  private func collapseSection(index index: Int){
    let viewItems = viewData
    let parent = viewItems[index]
    let firstChild = index+1
    
    // parent
    parent.collapsed = !parent.collapsed
    tableViewReloadRow(indexRow: index)
    
    // children
    for i in firstChild..<viewItems.count {
      let child = viewItems[i]
      if child.indent <= parent.indent {
        break
      }
      child.collapsed = parent.collapsed
      // remove forwards
      tableViewRemoveRow(indexRow: firstChild)
    }
  }
  
  
  
  // MARK: - SWIPE INDENT
  private func toggleIndent(cell cell:UITableViewCell, increase: Bool) {
    if let indexPath = tableView.indexPathForCell(cell) {
      print(indexPath.row)
      indentSection(index: indexPath.row, increase: increase)
    }
  }
  
  private func indentSection(index index: Int, increase: Bool) {
    let viewItems = viewData
    let realItems = realData
    let parent = viewItems[index]
    if parent.collapsed {
      // children
      var parentFound = false
      for i in 0..<realItems.count {
        let child = realItems[i]
        if child === parent {
          parentFound = true
          continue
        }
        
        if parentFound {
          if child.indent <= parent.indent {
            break
          }
          child.indent += (increase) ? 1 : (child.indent == 0) ? 0 : -1
        }
      }
    }
    // parent
    parent.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
    tableViewReloadRow(indexRow: index)
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
  private func initSwipeCell(indexPath indexPath: NSIndexPath) -> SwipeCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SwipeCell
    cell.swipeDelegate = self
    
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: .blueColor()) { (cell) -> () in
      //      self.deleteCell(cell: cell)
      self.toggleIndent(cell: cell, increase: false)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right2, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .redColor()) { (cell) -> () in
      //      self.deleteCell(cell: cell)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right3, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "clock")), color: .orangeColor()) { (cell) -> () in
      //      self.deleteCell(cell: cell)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right4, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: .greenColor()) { (cell) -> () in
      //      self.deleteCell(cell: cell)
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: .purpleColor()) { (cell) -> () in
      //      self.deleteCell(cell: cell)
      self.toggleIndent(cell: cell, increase: true)
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
  
  
  private func initDefaultCellLayout(cell cell: SwipeCell) -> SwipeCell {
    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    cell.selectionStyle = .None
    return cell
  }
  
  private func initCellLayout(cell cell: SwipeCell, indexPath: NSIndexPath) -> SwipeCell {
    let item = viewData[indexPath.row]
    var indent = " "
    for _ in 0...item.indent*8 {
      indent += " "
    }
    
    cell.textLabel?.text = indent + item.name
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
    viewData.append(ViewData(name: "4.0.0", indent: 0, collapsed: false))
    viewData.append(ViewData(name: "3.1.0", indent: 1, collapsed: false))
    viewData.append(ViewData(name: "3.1.1", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.1.2", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.1.3", indent: 2, collapsed: false))
    viewData.append(ViewData(name: "3.2.0", indent: 1, collapsed: false))
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
    realData  = viewData
  }
}
