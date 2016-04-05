//
//  Tag.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 4/4/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class Tag: NSObject, NSCoding {
  // PROPERTIES
  var title: String
  override var description: String {
    return "\(title)"
  }
  
  // INIT
  init?(title: String) {
    self.title = title
    
    super.init()
    
    if title.isEmpty {
      return nil
    }
  }
  
  // SAVE
  struct PropertyKey {
    static let title = "title"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(title, forKey: PropertyKey.title)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    self.init(title: title)
  }
}