import UIKit


//
//protocol CollapseCellDelegate {
//
//}
//
//class CollapseCell: CollapseCellDelegate {
//  
//  
//  // MARK: - TABLEVIEW MODIFICATION
//  func tableViewRemoveRow(indexRow indexRow: Int, tableView: UITableView) {
//    tableView.beginUpdates()
//    viewData.removeAtIndex(indexRow)
//    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//  
//  func tableViewInsertRow(viewData viewData: Array<AnyObject>, item: ViewDataItem, indexRow: Int) {
//    var viewData = viewData
//    tableView.beginUpdates()
//    viewData.insert(item, atIndex: indexRow)
//    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//  
//  func tableViewReloadRow(indexRow indexRow: Int) {
//    tableView.beginUpdates()
//    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//}
//
//
//extension UITableViewController {
//  
//  
//  // MARK: - TABLEVIEW MODIFICATION
//  func tableViewRemoveRow(viewData viewData: Array<AnyObject>, indexRow: Int) {
//    var viewData = viewData
//    tableView.beginUpdates()
//    viewData.removeAtIndex(indexRow)
//    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//  
//  func tableViewInsertRow(viewData viewData: Array<AnyObject>, item: ViewDataItem, indexRow: Int) {
//        var viewData = viewData
//    tableView.beginUpdates()
//    viewData.insert(item, atIndex: indexRow)
//    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//  
//  func tableViewReloadRow(indexRow indexRow: Int) {
//    tableView.beginUpdates()
//    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
//    tableView.endUpdates()
//  }
//  
//  
//  private func expandSection(index index: Int, viewData: Array<Collapsable>, realData: Array<Collapsable>) {
//    let viewItems = viewData
//    let realItems = realData
//    var parent = viewItems[index]
//    let firstChild = index+1
//    
//    // parent
//    parent.collapsed = !parent.collapsed
//    tableViewReloadRow(indexRow: index)
//    
//    // children
//    var children = [ViewDataItem]()
//    var parentFound = false
//    for i in 0..<realItems.count {
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
//      tableViewInsertRow(item: child, indexRow: firstChild)
//    }
//  }
//  
//  private func collapseSection(index index: Int){
//    let viewItems = viewData.items
//    let parent = viewItems[index]
//    let firstChild = index+1
//    
//    // parent
//    parent.collapsed = !parent.collapsed
//    tableViewReloadRow(indexRow: index)
//    
//    // children
//    for i in firstChild..<viewItems.count {
//      let child = viewItems[i]
//      if child.indent <= parent.indent {
//        break
//      }
//      child.collapsed = parent.collapsed
//      // remove forwards
//      tableViewRemoveRow(indexRow: firstChild)
//    }
//  }
//}