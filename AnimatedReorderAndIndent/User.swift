//
//  User.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 4/4/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
  // PROPERTIES
  var email: String
  var password: String
  var tasks: [Task]
  override var description: String {
    return "\(email)"
  }
  
  // INIT
  init?(email: String, password: String, tasks: [Task]) {
    self.email = email
    self.password = password
    self.tasks = tasks
    
    super.init()
    
    if email.isEmpty || password.isEmpty {
      return nil
    }
  }
  
  // SAVE
  struct PropertyKey {
    static let email = "email"
    static let password = "password"
    static let tasks = "tasks"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(email, forKey: PropertyKey.email)
    aCoder.encodeObject(password, forKey: PropertyKey.password)
    aCoder.encodeObject(tasks, forKey: PropertyKey.tasks)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let email = aDecoder.decodeObjectForKey(PropertyKey.email) as! String
    let password = aDecoder.decodeObjectForKey(PropertyKey.password) as! String
    let tasks = aDecoder.decodeObjectForKey(PropertyKey.tasks) as! [Task]
    self.init(email: email, password: password, tasks: tasks)
  }
  
  // ACCESS
  static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
  
  static func get(completion completion: (user: User?) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User {
        completion(user: data)
      } else {
        completion(user: nil)
      }
    })
  }
  
  static func set(data data: User, completion: (success: Bool) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: User.ArchiveURL.path!)
      if !isSuccessfulSave {
        completion(success: false)
      } else {
        completion(success: true)
      }
    })
  }
}