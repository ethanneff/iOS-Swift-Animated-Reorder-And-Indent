import Foundation

//protocol Arrayable {
//  var items: [ViewDataItem] { get set }
//}

protocol Collapsable {
  var collapsed: Bool { get set }
}

protocol Indentable {
  var indent: Int { get }
}

//class ViewData: Arrayable, CustomStringConvertible {
//  var items: [ViewDataItem] = [ViewDataItem]()
//  var description: String {
//    if items.count == 0 {
//      return "[]"
//    }
//    var output = "["
//    for i in 0..<items.count {
//      output += "\n  " + items[i].description + ","
//    }
//    output += "\n]"
//    return output
//  }
//  
//  func toggleCollapse(itemIndex: Int, includeChildren: Bool) {
//    let parent = items[itemIndex]
//    parent.collapsed = !parent.collapsed
//    if includeChildren {
//      for i in itemIndex+1..<items.count {
//        let child = items[i]
//        if child.indent <= parent.indent {
//          break
//        }
//        child.collapsed = parent.collapsed
//      }
//    }
//  }
//  
//  func toggleIndent(itemIndex: Int, increase: Bool, includeChildren: Bool) {
//    let parent = items[itemIndex]
//    if includeChildren {
//      for i in itemIndex+1..<items.count {
//        let child = items[i]
//        if child.indent <= parent.indent {
//          break
//        }
//        child.indent += (increase) ? 1 : (child.indent == 0) ? 0 : -1
//      }
//    }
//    parent.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
//  }
//}

class TableViewControllerData: Indentable, Collapsable, CustomStringConvertible {
  var name: String
  var collapsed: Bool
  var indent: Int
  var description: String {
    return "\n[indent: \(indent), collapsed: \(collapsed), name: \(name)]"
  }
  
  init(name: String, indent: Int, collapsed: Bool) {
    self.name = name
    self.indent = indent
    self.collapsed = collapsed
  }
  
  convenience init(name: String) {
    self.init(name: name, indent: 0, collapsed: false)
  }
  
  class func loadTestData() -> [TableViewControllerData] {
    var array = [TableViewControllerData]()
    array.append(TableViewControllerData(name: "1.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "1.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "1.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "1.2.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "1.2.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "1.3.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "1.3.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "1.3.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "1.4.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "2.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "2.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "2.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "2.2.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "2.2.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "2.3.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "2.3.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "2.3.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "2.4.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "3.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "3.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "3.1.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "3.1.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "3.1.3", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "3.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "4.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "5.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "5.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "5.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "5.2.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "5.2.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "5.3.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "5.4.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "6.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "6.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "6.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "6.2.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "6.2.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "6.3.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "6.4.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "7.0.0", indent: 0, collapsed: false))
    array.append(TableViewControllerData(name: "7.1.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "7.1.1", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "7.1.2", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "7.1.3", indent: 2, collapsed: false))
    array.append(TableViewControllerData(name: "7.2.0", indent: 1, collapsed: false))
    array.append(TableViewControllerData(name: "8.0.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.0.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.1", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.2", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.3", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.2.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.0.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.0.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.1", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.2", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.1.3", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.2.0", indent: 0, collapsed: false))
//    array.append(TableViewControllerData(name: "9.0.0", indent: 0, collapsed: false))
    return array
  }
}