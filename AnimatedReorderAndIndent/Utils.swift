//
//  Utils.swift
//  AnimatedReorderAndIndent
//
//  Created by Ethan Neff on 4/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//


import UIKit
import AVFoundation

class Util {
  
  // multiple story board navigation
  class func navToStoryboard(currentController currentController:UIViewController, storyboard:String) {
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    let controller = storyboard.instantiateInitialViewController()! as UIViewController
    currentController.presentViewController(controller, animated: true, completion: nil)
  }
  
  // changing the status bar color
  class func setStatusBarBackgroundColor(color: UIColor) {
    guard let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
      return
    }
    statusBar.backgroundColor = color
  }
  
  // background thread delay
  class func delay(delay:Double, closure:()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
  
  // logging
  class func log(logMessage: String?=nil, functionName: String = #function) {
    let currentDateTime = Int64(NSDate().timeIntervalSince1970*1000)
    print("[\(currentDateTime)] [\(functionName)] \(logMessage)")
  }
  
  // random
  class func randomString(length length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: length)
    
    for _ in 0..<length {
      let len = UInt32(letters.length)
      let rand = arc4random_uniform(len)
      randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return String(randomString)
  }
  
  class func randomNumber(upperLimit upperLimit: UInt32) -> Int {
    return Int(arc4random_uniform(upperLimit))
  }
  
  // threading
  class func threadBackground(completion: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      completion()
    }
  }
  
  class func threadMain(completion: () -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      completion()
    }
  }
  
  // animation
  class func animateButtonPress(button button: UIButton) {
    if let color = button.backgroundColor {
      UIView.animateWithDuration(0.2) { () -> Void in
        button.backgroundColor = color.colorWithAlphaComponent(0.7)
        UIView.animateWithDuration(0.3) { () -> Void in
          button.backgroundColor = color
        }
      }
    }
  }
  
  // sounds
  enum SystemSounds: UInt32 {
    case Tap = 1104
    case Positive = 1054
    case Negative = 1053
    case MailReceived = 1000
    case MailSent = 1001
    case SMSReceived = 1003
    case SMSSent = 1004
    case CalendarAlert = 1005
    case LowPower = 1006

  }

  class func playSound(systemSound systemSound: SystemSounds) {
    let systemSoundID: SystemSoundID = systemSound.rawValue
    AudioServicesPlaySystemSound(systemSoundID)
  }
}


// add hex to UIColor function to UIColor
extension UIColor {
  convenience init(hex: String) {
    let hex = hex.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
    var int = UInt32()
    NSScanner(string: hex).scanHexInt(&int)
    let a, r, g, b: UInt32
    switch hex.characters.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

// add guid: String property to UITableViewCell
extension UITableViewCell {
  private struct AssociatedKeys {
    static var guid:String?
  }
  
  var guid: String? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.guid) as? String
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.guid, newValue as String?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

// basic string functions
extension String {
  var isBlank: Bool {
    get {
      let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      return trimmed.isEmpty
    }
  }
  var isEmail: Bool {
    do {
      let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
    } catch {
      return false
    }
  }
  var isPhoneNumber: Bool {
    let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
    var filtered:NSString!
    let inputString:NSArray = self.componentsSeparatedByCharactersInSet(charcter)
    filtered = inputString.componentsJoinedByString("")
    return  self == filtered
  }
  var isPassword: Bool {
    do {
      // 8+, 1 num, 1 letter, 1 cap, 1 lower
      let regex = try NSRegularExpression(pattern: "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$", options: .CaseInsensitive)
      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
    } catch {
      return false
    }
  }
  var trim: String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
  var length: Int {
    return self.characters.count
  }
}