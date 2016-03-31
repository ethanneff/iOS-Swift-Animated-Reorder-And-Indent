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

class ViewData: Indentable, Collapsable, CustomStringConvertible {
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
}