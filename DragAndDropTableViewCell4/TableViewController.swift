//
//  TableViewController.swift
//  DragAndDropTableViewCell
//
//  Created by Ethan Neff on 2/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
  // MARK: - PROPERTIES
  var realData : [Data] = []
  var viewData : [Data] = []
  
  // MARK: - INIT
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // reorder
    tableView = ReorderTableView(tableView: tableView)
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderDelegate = self
    }
    
    
    
    // nav controller properties
    navigationController?.navigationBarHidden = true
    
    // table properties
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    // collpase
    let collpase = UITapGestureRecognizer(target: self, action: "doubleTapGesture:")
    collpase.numberOfTapsRequired = 2
    tableView.addGestureRecognizer(collpase)
    
    // data
    addData()
  }
  
  // MARK: - BUTTONS
  @IBAction func right(button: UIBarButtonItem) {
    print("right")
  }
  @IBAction func left(button: UIBarButtonItem) {
    print("left")
  }
  
  
  // MARK: - DOUBLE TAP
  func doubleTapGesture(touch: UITapGestureRecognizer) {
    // toggle collapse/expand section
    let location = touch.locationInView(tableView)
    if let index = tableView.indexPathForRowAtPoint(location),
      let cell = tableView.cellForRowAtIndexPath(index) {
        let viewCellData = viewData[index.row]
        viewCellData.collapsed = !viewCellData.collapsed
        if viewCellData.collapsed {
          collapseSection(index: index, cell: cell)
        } else {
          expandSection(index: index, cell: cell)
        }
    }
  }
  
  func collapseSection(index index: NSIndexPath, cell: UITableViewCell) {
    let row = index.row
    let section = viewData[row]
    let next = row+1
    var nextSection = false
    while !nextSection {
      if next > viewData.count-1 {
        break
      }
      
      if viewData[next].indent > section.indent {
        tableViewRemoveRow(indexRow: next)
      } else {
        nextSection = true
      }
    }
  }
  
  func expandSection(index index: NSIndexPath, cell: UITableViewCell) {
    let row = index.row
    let section = viewData[row]
    
    var headerFound = false
    var contents = [Data]()
    for i in 0...realData.count-1 {
      if realData[i] === section {
        headerFound = true
        continue
      } else if headerFound {
        if realData[i].indent > section.indent {
          contents.insert(realData[i], atIndex: 0)
        } else {
          break
        }
      }
    }
    
    for item in contents {
      tableViewInsertRow(item: item,indexRow: row+1)
    }
  }
  
    // MARK: - REORDER
  override func reorderBefore(fromIndexPath: NSIndexPath) {
    // collapse all rows that are not the correct indent level
    collapseCellsBelow(indexRow: fromIndexPath.row)
    let newIndex = collapseCellsAbove(indexRow: fromIndexPath.row)
    
    // pass back to tableview
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderInitalIndexPath = newIndex
    }
  }


  override func reorderAfter(fromIndexPath: NSIndexPath, toIndexPath:NSIndexPath) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      var realIndex = toIndexPath
      if fromIndexPath.row != toIndexPath.row {
        realIndex = self.reorderUpdateRealData(fromIndex: fromIndexPath, toIndex: toIndexPath)
      }
      dispatch_async(dispatch_get_main_queue()) {
        print(self.viewData[toIndexPath.row])
        self.viewData = self.realData
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(realIndex, atScrollPosition: .Top, animated: false)
        
        //        UIView.transitionWithView(<#T##view: UIView##UIView#>, duration: <#T##NSTimeInterval#>, options: UIViewAnimationOptions.CurveEaseIn, animations: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          
        })
        
        UIView.transitionWithView(self.tableView,
          duration:0.35,
          options:UIViewAnimationOptions.CurveEaseInOut,
          animations:
          { () -> Void in
            
          },
          completion: nil);
        //        self.tableView.reloadData()
        
        
        //        let row = fromIndex.row < toIndex.row ? toIndex.row: toIndex.row
        //
        //        print(self.viewData)
        //
        //        for i in 0..<self.viewData.count {
        //
        //          self.tableViewRemoveRow(indexRow: 0)
        //
        //        }
        //
        //        print( self.viewData)
        //        for i in 0..<self.realData.count {
        //          self.tableViewInsertRow(item: self.realData[i], indexRow: i)
        //          if i > realIndex.row {
        //            self.tableView.scrollToRowAtIndexPath(realIndex, atScrollPosition: .Top, animated: false)
        //          }
        //
        //        }
        //
      }
    }
  }
  
  func reorderUpdateViewData(fromIndex fromIndex: NSIndexPath, toIndex:NSIndexPath) {
    // update view data (reorder based on direction moved)
    let ascending = fromIndex.row < toIndex.row ? true : false
    
    let viewFromData = viewData[fromIndex.row]
    let viewFromIndex = ascending ? fromIndex.row : fromIndex.row+1
    let viewToIndex = ascending ? toIndex.row+1 : toIndex.row
    viewData.insert(viewFromData, atIndex: viewToIndex)
    viewData.removeAtIndex(viewFromIndex)
  }
  
  func reorderUpdateRealData(fromIndex fromIndex: NSIndexPath, toIndex:NSIndexPath) -> NSIndexPath {
    // view data
    let ascending = fromIndex.row < toIndex.row ? true : false
    let fromViewData = viewData[fromIndex.row]
    let toViewData = viewData[toIndex.row]
    
    // set real search
    var fromRealDataStart = -1
    var fromRealDataFinish = -1
    var toRealDataStart = -1
    var toRealDataFinish = -1
    
    var fromRealDataFinishDone = false
    var toRealDataFinishDone = false
    
    // find the real indexes from the view indexes
    for i in 0..<realData.count {
      realData[i].collapsed = false
      
      if realData[i] === fromViewData {
        fromRealDataStart = i
      }
      
      if realData[i] === toViewData {
        toRealDataStart = i
      }
      
      if realData[i] !== fromViewData && fromRealDataStart != -1 && !fromRealDataFinishDone {
        if realData[i].indent > realData[fromRealDataStart].indent {
          fromRealDataFinish = i
        } else {
          fromRealDataFinish = fromRealDataFinish == -1 ? i-1 : fromRealDataFinish
          fromRealDataFinishDone = true
        }
      }
      
      if realData[i] !== toViewData && toRealDataStart != -1 && !toRealDataFinishDone {
        if realData[i].indent > realData[toRealDataStart].indent {
          toRealDataFinish = i
        } else {
          toRealDataFinish = toRealDataFinish == -1 ? i-1 : toRealDataFinish
          toRealDataFinishDone = true
        }
      }
    }
    // handle end indexes
    fromRealDataFinish = fromRealDataFinish == -1 ? realData.count-1 : fromRealDataFinish
    toRealDataFinish = toRealDataFinish == -1 ? realData.count-1 : toRealDataFinish
    
    // set range
    let fromRealRange = fromRealDataStart...fromRealDataFinish
    
    // set real data
    let fromRealData = realData[fromRealRange]
    
    // handle direction
    let toIndex = ascending ? toRealDataFinish+1-fromRealData.count : toRealDataStart
    
    // update real data
    realData.removeRange(fromRealRange)
    realData.insertContentsOf(fromRealData, at: toIndex)
    
    // pass back new index
    return NSIndexPath(forRow: toIndex, inSection: 0)
  }
  
  // MARK: - COLLAPSE CELL
  func collapseCellsBelow(indexRow indexRow: Int) {
    let indent = viewData[indexRow].indent
    var indexDown = indexRow+1
    while true {
      if indexDown == viewData.count {
        break
      }
      if viewData[indexDown].indent != indent {
        tableViewRemoveRow(indexRow: indexDown)
      } else {
        indexDown++
      }
    }
  }
  
  func collapseCellsAbove(indexRow indexRow: Int) -> NSIndexPath {
    let indent = viewData[indexRow].indent
    var indexUp = indexRow-1
    var indexChange = 0
    while true {
      if indexUp == -1 {
        break
      }
      if viewData[indexUp].indent != indent {
        tableViewRemoveRow(indexRow: indexUp)
        indexChange++
      }
      indexUp--
    }
    
    return NSIndexPath(forItem: indexRow-indexChange, inSection: 0)
  }
  
  
  // MARK: - TABLEVIEW MODIFICATION
  func tableViewRemoveRow(indexRow indexRow: Int) {
    tableView.beginUpdates()
    viewData.removeAtIndex(indexRow)
    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  func tableViewInsertRow(item item: Data, indexRow: Int) {
    tableView.beginUpdates()
    viewData.insert(item, atIndex: indexRow)
    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
    tableView.endUpdates()
  }
  
  
  
  // MARK: - TABLEVIEW DATA SOURCE
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
    var g = Data(name: "1.3.1", parent: f, indent: 2)
    var h = Data(name: "1.3.2", parent: f, indent: 2)
    var i = Data(name: "1.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    //    viewData.append(c)
    //    viewData.append(d)
    //    viewData.append(e)
    //    viewData.append(f)
    //    viewData.append(g)
    //    viewData.append(h)
    viewData.append(i)
    
    a = Data(name: "2.0.0", parent: nil, indent: 0)
    b = Data(name: "2.1.0", parent: a, indent: 1)
    c = Data(name: "2.2.0", parent: a, indent: 1)
    d = Data(name: "2.2.1", parent: c, indent: 2)
    e = Data(name: "2.2.2", parent: c, indent: 2)
    f = Data(name: "2.3.0", parent: a, indent: 1)
    g = Data(name: "2.3.1", parent: f, indent: 2)
    h = Data(name: "2.3.2", parent: f, indent: 2)
    i = Data(name: "2.4.0", parent: a, indent: 1)
    
    viewData.append(a)
    viewData.append(b)
    //    viewData.append(c)
    //    viewData.append(d)
    //    viewData.append(e)
    //    viewData.append(f)
    //    viewData.append(g)
    viewData.append(h)
    viewData.append(i)
    
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
    //    viewData.append(e)
    //    viewData.append(f)
    //    viewData.append(g)
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
  var collapsed: Bool = false
  
  
  var description: String {
    return "\(name)"
  }
  
  init(name: String, parent: Data?, indent: Int) {
    self.name = name
    self.parent = parent
    self.indent = indent
  }
  
}

