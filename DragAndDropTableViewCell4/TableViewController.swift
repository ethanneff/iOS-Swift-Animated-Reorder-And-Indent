//
//  TableViewController.swift
//  DragAndDropTableViewCell
//
//  Created by Ethan Neff on 2/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIGestureRecognizerDelegate {
  // MARK: - PROPERTIES
  var realData : [Data] = []
  var viewData : [Data] = []

  
  
  // MARK: - INIT
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // reorder
    tableView = ReorderTableView(tableView: tableView)
    
    // nav controller properties
    //    navigationController?.navigationBarHidden = true
    
    // table properties
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    addData()
  }
  
  
  
  // MARK: - BUTTONS
  @IBAction func right(button: UIBarButtonItem) {
    print("right")
  }
  @IBAction func left(button: UIBarButtonItem) {
    print("left")
  }
  
  
  
  // MARK: - COLLAPSE CELL
  func collapseBelow(indexRow indexRow: Int) {
    var indexDown = indexRow+1
    while true {
      if indexDown == viewData.count {
        break
      }
      if viewData[indexDown].indent != viewData[indexRow].indent {
        collapseRemoveRow(indexRow: indexDown)
      } else {
        indexDown++
      }
    }
  }
  
  func collapseAbove(indexRow indexRow: Int) -> NSIndexPath {
    var indexUp = indexRow-1
    var indexChange = 0
    while true {
      if indexUp == -1 {
        break
      }
      if viewData[indexUp].indent != viewData[indexRow].indent {
        collapseRemoveRow(indexRow: indexUp)
        indexChange++
      }
      indexUp--
    }
    
    return NSIndexPath(forItem: indexRow-indexChange, inSection: 0)
  }
  
  func collapseRemoveRow(indexRow indexRow: Int) {
    tableView.beginUpdates()
    viewData.removeAtIndex(indexRow)
    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  // MARK: - EXPAND CELL
  
  
  
  // MARK: - REORDER
  func reorderBefore(index: NSIndexPath) {
    // collapse all rows that are not the correct indent level
    collapseBelow(indexRow: index.row)
    let newIndex = collapseAbove(indexRow: index.row)
    
    // pass back to tableview
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderInitalIndexPath = newIndex
    }
  }
  
  func reorderAfter(fromIndex: NSIndexPath, toIndex:NSIndexPath) {
    // update view data (reorder based on direction moved)
    let ascending = fromIndex.row < toIndex.row ? true : false
    let from = ascending ? fromIndex.row : fromIndex.row+1
    let to = ascending ? toIndex.row+1 : toIndex.row

    
    print(viewData[fromIndex.row])
    print(viewData[toIndex.row])
    
    print(realData[fromIndex.row])
    print(realData[toIndex.row])
    viewData.insert(viewData[fromIndex.row], atIndex: to)
    viewData.removeAtIndex(from)
    print(viewData)
    
    // update real data
    
    
    // animate view data (expand)
    
    // reorder the realData
    // update tableview
    // animate tableview
    
    
    // bring back other items and sort them
  }
  
  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewData.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    
    // cell properties
    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    cell.selectionStyle = .None
    let item = viewData[indexPath.row]
    var indent = " "
    for _ in 0...item.indent*8 {
      indent += " "
    }
    
    cell.textLabel?.text = indent + viewData[indexPath.row].name
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  func addData() {
    viewData.removeAll()
    var a = Data(name: "1.0.0", parent: nil, indent: 0)
    var b = Data(name: "1.1.0", parent: a, indent: 1)
    var c = Data(name: "1.2.0", parent: a, indent: 1)
    var d = Data(name: "1.2.1", parent: c, indent: 2)
    var e = Data(name: "1.2.2", parent: c, indent: 2)
    var f = Data(name: "1.3.0", parent: a, indent: 1)
    var g = Data(name: "1.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    
    a = Data(name: "2.0.0", parent: nil, indent: 0)
    b = Data(name: "2.1.0", parent: a, indent: 1)
    c = Data(name: "2.2.0", parent: a, indent: 1)
    d = Data(name: "2.2.1", parent: c, indent: 2)
    e = Data(name: "2.2.2", parent: c, indent: 2)
    f = Data(name: "2.3.0", parent: a, indent: 1)
    g = Data(name: "2.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    
    a = Data(name: "3.0.0", parent: nil, indent: 0)
    b = Data(name: "4.0.0", parent: nil, indent: 0)
    c = Data(name: "3.1.0", parent: a, indent: 1)
    d = Data(name: "3.1.1", parent: c, indent: 2)
    e = Data(name: "3.1.2", parent: c, indent: 2)
    f = Data(name: "3.1.3", parent: c, indent: 2)
    g = Data(name: "3.2.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    viewData.append(b)
    
    
    a = Data(name: "5.0.0", parent: nil, indent: 0)
    b = Data(name: "5.1.0", parent: a, indent: 1)
    c = Data(name: "5.2.0", parent: a, indent: 1)
    d = Data(name: "5.2.1", parent: c, indent: 2)
    e = Data(name: "5.2.2", parent: c, indent: 2)
    f = Data(name: "5.3.0", parent: a, indent: 1)
    g = Data(name: "5.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    
    a = Data(name: "6.0.0", parent: nil, indent: 0)
    b = Data(name: "6.1.0", parent: a, indent: 1)
    c = Data(name: "6.2.0", parent: a, indent: 1)
    d = Data(name: "6.2.1", parent: c, indent: 2)
    e = Data(name: "6.2.2", parent: c, indent: 2)
    f = Data(name: "6.3.0", parent: a, indent: 1)
    g = Data(name: "6.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    
    a = Data(name: "7.0.0", parent: nil, indent: 0)
    b = Data(name: "7.1.0", parent: a, indent: 1)
    c = Data(name: "7.1.1", parent: c, indent: 2)
    d = Data(name: "7.1.2", parent: c, indent: 2)
    e = Data(name: "7.1.3", parent: c, indent: 2)
    f = Data(name: "7.2.0", parent: a, indent: 1)
    g = Data(name: "8.0.0", parent: nil, indent: 0)
    
    viewData.append(a)
    viewData.append(b)
    viewData.append(c)
    viewData.append(d)
    viewData.append(e)
    viewData.append(f)
    viewData.append(g)
    
    realData = viewData
  }
}

class Data: CustomStringConvertible {
  var name: String
  var parent: Data?
  var indent: Int = 0
  
  
  var description: String {
    return "\(name)"
  }
  
  init(name: String, parent: Data?, indent: Int) {
    self.name = name
    self.parent = parent
    self.indent = indent
  }
  
}
