//
//  MenuViewController.swift
//  NotesApp
//
//  Created by Ethan Neff on 4/6/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
  // MARK: - properties
  @IBOutlet weak var mainContainer: UIView!
  @IBOutlet weak var menuLeft: UIView!
  @IBOutlet weak var menuRight: UIView!
  
  let menuSpeed: NSTimeInterval = 0.35
  let menuFade: CGFloat = 0.9
  let menuShadow: Float = 0.7
  let menuPanMinPercentage: CGFloat = 10
  
  private var menuPanBeganLocation: CGPoint = CGPointZero
  private var menuPanEndedLocation: CGPoint = CGPointZero
  private var menuPanBeganHorizontal: Bool = false
  private var menuGestureSingleTap: UITapGestureRecognizer?
  private var menuGesturePanSwipe: UIPanGestureRecognizer?
  
  private enum MenuPanDirection {
    case Left
    case Right
  }
  
  private enum MenuSide {
    case Left
    case Right
    case Center
  }
  
  
  // MARK: - load
  override func viewDidLoad() {
    super.viewDidLoad()
    setupContainersProperties()
    initGestures()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupContainerPositions()
  }
  
  private func setupContainersProperties() {
    // fix container spacing
    automaticallyAdjustsScrollViewInsets = false
    // set to make background container fade
    view.backgroundColor = .blackColor()
    
    let containers = [mainContainer, menuLeft, menuRight]
    for container in containers {
      container.backgroundColor = Global.colorBackground
      container.layer.masksToBounds = true
      container.layer.shadowColor = UIColor.blackColor().CGColor
      container.layer.shadowOpacity = menuShadow
      container.layer.shadowOffset = CGSizeZero
      container.layer.shadowRadius = 5
    }
  }
  
  private func setupContainerPositions() {
    // for collapsing the menus on device rotate
    menuLeft.frame.origin.x -= menuLeft.frame.size.width
    menuRight.frame.origin.x += menuRight.frame.size.width
  }
  
  
  
  // MARK: - errors
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  
  // MARK: - buttons
  @IBAction func leftNavButtonPressed(sender: AnyObject) {
    menuToggle(menuSide: .Left)
  }
  @IBAction func rightNavButtonPressed(sender: AnyObject) {
    menuToggle(menuSide: .Right)
  }
  
  
  // MARK: - gestures
  private func initGestures() {
    menuGestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    menuGestureSingleTap!.numberOfTapsRequired = 1
    view.addGestureRecognizer(menuGestureSingleTap!)
    menuGesturePanSwipe = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizedPanSwipe(_:)))
    menuGesturePanSwipe!.minimumNumberOfTouches = 1
    view.addGestureRecognizer(menuGesturePanSwipe!)
  }
  
  internal func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(view)
    if touchInMainContainer(location: location) {
      menuToggle(menuSide: .Center)
    }
  }
  
  private func touchInMainContainer(location location: CGPoint) -> Bool {
    if menuIsVisible(container: menuLeft) {
      return location.x > menuLeft.frame.origin.x + menuLeft.frame.size.width
    } else if menuIsVisible(container: menuRight) {
      return location.x < menuRight.frame.origin.x
    }
    return false
  }
  
  internal func gestureRecognizedPanSwipe(gesture: UIPanGestureRecognizer) {
    let state = gesture.state
    let location = gesture.locationInView(view)
    let velocity = gesture.velocityInView(view)
    
    switch state {
    case .Began:
      menuPanBeganLocation = location
      menuPanBeganHorizontal = menuPanHorizontal(velocity: velocity)
    case .Changed: break
    case .Cancelled, .Ended:
      menuPanEndedLocation = location
      let direction = menuPanDirection(beganLocation: menuPanBeganLocation, endedLocation: menuPanEndedLocation)
      let percentage = menuPanPercentage(beganLocation: menuPanBeganLocation, endedLocation: menuPanEndedLocation)
      let correct = menuPanCorrect(direction: direction, percentage: percentage, horizontal: menuPanBeganHorizontal)
      if correct {
        menuToggle(menuSide: .Center)
      }
      menuPanReset()
    default: break
    }
  }
  
  private func menuPanDirection(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> MenuPanDirection {
    return endedLocation.x > beganLocation.x ? .Right : .Left
  }
  
  private func menuPanPercentage(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> CGFloat {
    if menuIsVisible(container: menuLeft) {
      return fabs(menuPanEndedLocation.x - menuPanBeganLocation.x) / menuLeft.frame.size.width * 100
    }
    return fabs(menuPanEndedLocation.x - menuPanBeganLocation.x) / menuRight.frame.size.width * 100
  }
  
  private func menuPanHorizontal(velocity velocity: CGPoint) -> Bool {
    return fabs(velocity.x) > fabs(velocity.y)
  }
  
  private func menuPanCorrect(direction direction: MenuPanDirection, percentage: CGFloat, horizontal: Bool) -> Bool {
    if menuIsVisible(container: menuLeft) {
      return direction == .Left && percentage > menuPanMinPercentage && horizontal
    } else if menuIsVisible(container: menuRight) {
      return direction == .Right && percentage > menuPanMinPercentage && horizontal
    }
    return false
  }
  
  private func menuPanReset() {
    menuPanBeganLocation = CGPointZero
    menuPanEndedLocation = CGPointZero
    menuPanBeganHorizontal = false
  }
  
  
  
  
  // MARK: - menus
  private func menuToggle(menuSide menuSide: MenuSide) {
    switch menuSide {
    case .Left:
      if menuIsVisible(container: menuRight) {
        menuRightAnimate {
          self.menuLeftAnimate()
        }
      } else {
        menuLeftAnimate()
      }
    case .Right:
      if menuIsVisible(container: menuLeft) {
        menuLeftAnimate {
          self.menuRightAnimate()
        }
      } else {
        menuRightAnimate()
      }
    case .Center:
      if menuIsVisible(container: menuLeft) {
        menuLeftAnimate()
      } else {
        menuRightAnimate()
      }
    }
  }
  
  private func menuLeftAnimate(completion: (() -> ())? = nil) {
    menuAnimate(menu: menuLeft, menuIsOpening: !menuIsVisible(container: menuLeft), menuSide: .Left, completion: {
      if let completion = completion {
        completion()
      }
    })
  }
  
  private func menuRightAnimate(completion: (() -> ())? = nil) {
    menuAnimate(menu: menuRight, menuIsOpening: !menuIsVisible(container: menuRight), menuSide: .Right, completion: {
      if let completion = completion {
        completion()
      }
    })
  }
  
  private func menuIsVisible(container container: UIView) -> Bool {
    return container.frame.origin.x >= 0 && container.frame.origin.x < view.frame.size.width
  }
  
  private func menuAnimate(menu menu: UIView, menuIsOpening: Bool, menuSide: MenuSide, completion: (() -> ())?) {
    menu.layer.masksToBounds = false
    mainContainer.userInteractionEnabled = menuIsOpening ? false : true
    
    UIView.animateWithDuration(menuSpeed, delay: 0.0, options: menuIsOpening ? .CurveEaseOut : .CurveEaseIn, animations: {
      self.mainContainer.alpha = menuIsOpening ? self.menuFade : 1.0
      
      switch menuSide {
      case .Left: menu.frame.origin.x -= menuIsOpening ? -menu.frame.size.width : menu.frame.size.width
      case .Right: menu.frame.origin.x -= menuIsOpening ? menu.frame.size.width : -menu.frame.size.width
      case .Center: break
      }
    }) { (success) in
      menu.layer.masksToBounds = menuIsOpening ? false : true
      if let completion = completion {
        completion()
      }
    }
  }
}
