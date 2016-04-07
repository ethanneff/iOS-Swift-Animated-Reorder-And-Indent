//
//  Tasks.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 4/4/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class Task: NSObject, NSCoding, DataCompleteable, DataCollapsible, DataIndentable, DataTagable {
  // PROPERTIES
  var title: String
  var body: String?
  var tags: [Tag] = []
  var indent: Int = 0
  var collapsed: Bool = false
  var children: Int = 0
  var completed: Bool = false
  override var description: String {
    return "\(title) \(indent) \(collapsed)" // | \(collapsed)"
  }
  
  // INIT
  init?(title: String, body: String?, tags: [Tag], indent: Int, collapsed: Bool, children: Int, completed: Bool) {
    self.title = title
    self.body = body
    self.tags = tags
    self.indent = indent
    self.collapsed = collapsed
    self.children = children
    self.completed = completed

    super.init()
    
    if title.isEmpty {
      return nil
    }
  }
  
  convenience init?(title: String) {
    self.init(title: title, body: nil, tags: [], indent: 0, collapsed: false, children: 0, completed: false)
  }
  
  convenience init?(title: String, indent: Int) {
    self.init(title: title, body: nil, tags: [], indent: indent, collapsed: false, children: 0, completed: false)
  }
  
  // METHODS
  class func loadTestData() -> [Task] {
    var array = [Task]()
    array.append(Task(title: "0", indent: 0)!)
    array.append(Task(title: "1", indent: 1)!)
    array.append(Task(title: "2", indent: 1)!)
    array.append(Task(title: "3", indent: 2)!)
    array.append(Task(title: "4", indent: 3)!)
    array.append(Task(title: "5", indent: 2)!)
    array.append(Task(title: "6", indent: 0)!)
    array.append(Task(title: "7", indent: 1)!)
    array.append(Task(title: "8", indent: 2)!)
    array.append(Task(title: "9", indent: 0)!)
    array.append(Task(title: "1.0.0", indent: 0)!)
    array.append(Task(title: "1.1.0", indent: 1)!)
    array.append(Task(title: "1.2.0", indent: 1)!)
    array.append(Task(title: "1.2.1", indent: 2)!)
    array.append(Task(title: "1.2.2", indent: 2)!)
    array.append(Task(title: "1.3.0", indent: 1)!)
    array.append(Task(title: "1.3.1", indent: 2)!)
    array.append(Task(title: "1.3.2", indent: 2)!)
    array.append(Task(title: "1.4.0", indent: 1)!)
    array.append(Task(title: "2.0.0", indent: 0)!)
    array.append(Task(title: "2.1.0", indent: 1)!)
    array.append(Task(title: "2.2.0", indent: 1)!)
    array.append(Task(title: "2.2.2", indent: 2)!)
    array.append(Task(title: "2.3.0", indent: 1)!)
    array.append(Task(title: "2.3.1", indent: 2)!)
    array.append(Task(title: "2.3.2", indent: 2)!)
    array.append(Task(title: "2.4.0", indent: 1)!)
    array.append(Task(title: "3.0.0", indent: 0)!)
    array.append(Task(title: "3.1.0", indent: 1)!)
    array.append(Task(title: "3.1.1", indent: 2)!)
    array.append(Task(title: "3.1.2", indent: 2)!)
    array.append(Task(title: "3.1.3", indent: 2)!)
    array.append(Task(title: "3.2.0", indent: 1)!)
    array.append(Task(title: "4.0.0", indent: 0)!)
    array.append(Task(title: "5.0.0", indent: 0)!)
    array.append(Task(title: "5.1.0", indent: 1)!)
    array.append(Task(title: "5.2.0", indent: 1)!)
    array.append(Task(title: "5.2.1", indent: 2)!)
    array.append(Task(title: "5.2.2", indent: 2)!)
    array.append(Task(title: "5.3.0", indent: 1)!)
    array.append(Task(title: "5.4.0", indent: 1)!)
    array.append(Task(title: "6.0.0", indent: 0)!)
    array.append(Task(title: "6.1.0", indent: 1)!)
    array.append(Task(title: "6.2.0", indent: 1)!)
    array.append(Task(title: "6.2.1", indent: 2)!)
    array.append(Task(title: "6.2.2", indent: 2)!)
    array.append(Task(title: "6.3.0", indent: 1)!)
    array.append(Task(title: "6.4.0", indent: 1)!)
    array.append(Task(title: "8.0.0", indent: 0)!)
    array.append(Task(title: "7.0.0", indent: 0)!)
    array.append(Task(title: "7.1.0", indent: 1)!)
    array.append(Task(title: "7.1.1", indent: 2)!)
    array.append(Task(title: "7.1.2", indent: 2)!)
    array.append(Task(title: "7.1.3", indent: 2)!)
    array.append(Task(title: "7.2.0", indent: 1)!)
    array.append(Task(title: "7.2.1", indent: 2)!)
    array.append(Task(title: "7.2.2", indent: 2)!)
    array.append(Task(title: "9.0.0", indent: 0)!)
//    array.append(Task(title: "9.1.0", indent: 0)!)
//    array.append(Task(title: "9.1.1", indent: 0)!)
//    array.append(Task(title: "9.1.2", indent: 0)!)
//    array.append(Task(title: "9.1.3", indent: 0)!)
//    array.append(Task(title: "9.2.0", indent: 0)!)
//    array.append(Task(title: "9.0.0", indent: 0)!)
//    array.append(Task(title: "9.0.0", indent: 0)!)
//    array.append(Task(title: "9.1.0", indent: 0)!)
//    array.append(Task(title: "9.1.1", indent: 0)!)
//    array.append(Task(title: "9.1.2", indent: 0)!)
//    array.append(Task(title: "9.1.3", indent: 0)!)
//    array.append(Task(title: "9.2.0", indent: 0)!)
    array.append(Task(title: "envision who you want to become in 2 minutes", indent: 0)!)
    return array
  }
  
  // SAVE  
  struct PropertyKey {
    static let title = "title"
    static let body = "body"
    static let tags = "tags"
    static let indent = "indent"
    static let collapsed = "collapsed"
    static let children = "children"
    static let completed = "completed"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(body, forKey: PropertyKey.body)
    aCoder.encodeObject(tags, forKey: PropertyKey.tags)
    aCoder.encodeObject(indent, forKey: PropertyKey.indent)
    aCoder.encodeObject(collapsed, forKey: PropertyKey.collapsed)
    aCoder.encodeObject(children, forKey: PropertyKey.children)
    aCoder.encodeObject(completed, forKey: PropertyKey.completed)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    let body = aDecoder.decodeObjectForKey(PropertyKey.body) as! String
    let tags = aDecoder.decodeObjectForKey(PropertyKey.tags) as! [Tag]
    let indent = aDecoder.decodeObjectForKey(PropertyKey.indent) as! Int
    let collapsed = aDecoder.decodeObjectForKey(PropertyKey.collapsed) as! Bool
    let children = aDecoder.decodeObjectForKey(PropertyKey.children) as! Int
    let completed = aDecoder.decodeObjectForKey(PropertyKey.completed) as! Bool
    
    self.init(title: title, body: body, tags: tags, indent: indent, collapsed: collapsed, children: children, completed: completed)
  }
}
