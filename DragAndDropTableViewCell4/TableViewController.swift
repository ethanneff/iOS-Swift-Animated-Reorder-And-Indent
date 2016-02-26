//
//  TableViewController.swift
//  DragAndDropTableViewCell
//
//  Created by Ethan Neff on 2/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIGestureRecognizerDelegate {
  // controller properties
  var items : [Data] = []
  
  @IBAction func right(sender: AnyObject) {
    
  }
  
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
  
  
  // MARK: - REORDER
//  func reorderBefore(index: NSIndexPath) {
//    let indexRow = index.row
//    let data = items[indexRow]
//    print("before")
//
//    var indexDown = indexRow+1
//    while true {
//      if indexDown == items.count {
//        break
//      }
//      if items[indexDown].indent != data.indent {
//        tableView.beginUpdates()
//        items.removeAtIndex(indexDown)
//        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexDown, inSection: 0)], withRowAnimation: .Fade)
//        tableView.endUpdates()
//      } else {
//        indexDown++
//      }
//      
//    }
//    
//    var indexUp = indexRow-1
//    var count = 0
//    while true {
//      if indexUp == -1 {
//        break
//      }
//      if items[indexUp].indent != data.indent {
//        tableView.beginUpdates()
//        items.removeAtIndex(indexUp)
//        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexUp, inSection: 0)], withRowAnimation: .Fade)
//        tableView.endUpdates()
//      count++
//      }
//      indexUp--
//
//    }
//    
//    // pass back to tableview
//    if let tableView = tableView as? ReorderTableView {
//      tableView.reorderInitalIndexPath = NSIndexPath(forItem: index.row-count, inSection: index.section)
//    }
//  }
//  
//  func reorderAfter() {
//    print("after")
//    addData()
//    tableView.reloadData()
//  }
//  
  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    
    // cell properties
    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    cell.selectionStyle = .None
    let item = items[indexPath.row]
    var indent = " "
    for _ in 0...item.indent*8 {
      indent += " "
    }
    
    cell.textLabel?.text = indent + items[indexPath.row].name
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  
  func addData() {
    items.removeAll()
    var a = Data(name: "1.0.0", parent: nil, indent: 0)
    var b = Data(name: "1.1.0", parent: a, indent: 1)
    var c = Data(name: "1.2.0", parent: a, indent: 1)
    var d = Data(name: "1.2.1", parent: c, indent: 2)
    var e = Data(name: "1.2.2", parent: c, indent: 2)
    var f = Data(name: "1.3.0", parent: a, indent: 1)
    var g = Data(name: "1.4.0", parent: a, indent: 1)
    
    items.append(a)
    items.append(b)
    items.append(c)
    items.append(d)
    items.append(e)
    items.append(f)
    items.append(g)
    
    a = Data(name: "2.0.0", parent: nil, indent: 0)
    b = Data(name: "2.1.0", parent: a, indent: 1)
    c = Data(name: "2.2.0", parent: a, indent: 1)
    d = Data(name: "2.2.1", parent: c, indent: 2)
    e = Data(name: "2.2.2", parent: c, indent: 2)
    f = Data(name: "2.3.0", parent: a, indent: 1)
    g = Data(name: "2.4.0", parent: a, indent: 1)
    
    items.append(a)
    items.append(b)
    items.append(c)
    items.append(d)
    items.append(e)
    items.append(f)
    items.append(g)
    
    a = Data(name: "3.0.0", parent: nil, indent: 0)
    b = Data(name: "4.0.0", parent: nil, indent: 0)
    c = Data(name: "3.1.0", parent: a, indent: 1)
    d = Data(name: "3.1.1", parent: c, indent: 2)
    e = Data(name: "3.1.2", parent: c, indent: 2)
    f = Data(name: "3.1.3", parent: c, indent: 2)
    g = Data(name: "3.2.0", parent: a, indent: 1)
    
    items.append(a)
    items.append(c)
    items.append(d)
    items.append(e)
    items.append(f)
    items.append(g)
    items.append(b)
    
  }
}

class Data {
  var name: String
  var parent: Data?
  var indent: Int = 0
  
  init(name: String, parent: Data?, indent: Int) {
    self.name = name
    self.parent = parent
    self.indent = indent
  }
}
