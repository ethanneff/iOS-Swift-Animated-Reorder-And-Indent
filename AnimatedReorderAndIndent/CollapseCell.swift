//
//  CollapseTableView.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 4/4/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

// TODO: figure out how to pass a protocol<DataCollapible, DataIndentable> as type instead of class Task
protocol CollapseControllerable {
  var tableViewData: [Task] { get set }
  var collapsedSections: [[Task]] { get set }
  weak var collapseDelegate: CollapseCellDelegate? { get set }
}

protocol CollapseCellDelegate: class {
  func toggleCollapse(tableView tableView: UITableView, tableViewData: [Task], collapsedSections: [[Task]], indexPath: NSIndexPath) -> [Task]
  func expandSection(tableView tableView: UITableView, tableViewData: [Task], collapsedSections: [[Task]], indexPath: NSIndexPath) -> [Task]
  func collapseSection(tableView tableView: UITableView, tableViewData: [Task], indexPath: NSIndexPath) -> [Task]
}

class CollapseCell: CollapseCellDelegate {
  
  func toggleCollapse(tableView tableView: UITableView, tableViewData: [Task], collapsedSections: [[Task]], indexPath: NSIndexPath) -> [Task] {
    let collapsed = tableViewData[indexPath.row].collapsed
    if collapsed {
      return expandSection(tableView: tableView, tableViewData: tableViewData, collapsedSections: collapsedSections, indexPath: indexPath)
    } else {
      return collapseSection(tableView: tableView, tableViewData: tableViewData, indexPath: indexPath)
    }
  }
  
  func expandSection(tableView tableView: UITableView, tableViewData: [Task], collapsedSections: [[Task]], indexPath: NSIndexPath) -> [Task] {
    return [Task(title: "Asoina")!]
  }
  
  func collapseSection(tableView tableView: UITableView, tableViewData: [Task], indexPath: NSIndexPath) -> [Task] {
    print("collapseSection")
    let parent = tableViewData[indexPath.row]
    let childIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
    let child = childIndexPath.row > tableViewData.count-1 ? tableViewData[tableViewData.count-1] : tableViewData[childIndexPath.row]
    
    // only collpase if parent has a child
    var section: [Task] = []
    if child.indent > parent.indent {
      // parent
      parent.collapsed = true
      
      // children
      for i in childIndexPath.row..<tableViewData.count {
        let child = tableViewData[i]
        if child.indent <= parent.indent {
          break
        }
        child.collapsed = true
        section.append(child)
      }
    }
    return section
  }
  
  
  //
  //  private func expandSection(indexPath indexPath: NSIndexPath) {
  //    let viewItems = viewData
  //    let realItems = realData
  //    let parent = viewItems[indexPath.row]
  //    let childIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
  //
  //    // parent
  //    parent.collapsed = false
  //    tableViewReloadRow(indexPath: indexPath)
  //
  //    print(viewData)
  //    print(realData)
  //
  //    // children
  //    var children = [TableViewControllerData]()
  //    var parentFound = false
  //    for i in 0..<realItems.count {
  //      // real items since already removed
  //      let child = realItems[i]
  //      if child === parent {
  //        parentFound = true
  //        continue
  //      }
  //
  //      if parentFound {
  //        if child.indent <= parent.indent {
  //          break
  //        }
  //        child.collapsed = parent.collapsed
  //        children.insert(child, atIndex: 0)
  //      }
  //    }
  //
  //    // insert backwards
  //    for child in children {
  //      tableViewInsertRow(indexPath: childIndexPath, data: child)
  //    }
  //  }
  
}