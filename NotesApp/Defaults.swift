//
//  Defaults.swift
//  NotesApp
//
//  Created by Ethan Neff on 4/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit



// MARK: GLOBALS COLORS
struct Global {
  static let colorButton = UIColor(hex:"#3498db")
  static let colorTitle =  UIColor(hex: "#212121")
  static let colorSubtitle = UIColor(hex: "#757575")
  static let colorBorder = UIColor(hex: "#cdcdcd")
  static let colorShadow = UIColor(hex: "#f5f5f5")
  static let colorBackground = UIColor(hex: "#ffffff")
  static let colorStatusBar = UIBarStyle.Default

  static let colorRed = UIColor(hex:"#ed5522")
  static let colorGreen = UIColor(hex:"#67d768")
  static let colorYellow = UIColor(hex:"#fed23b")
  static let colorBrown = UIColor(hex:"#d7a678")

  //  static let colorButton = UIColor(hex:"#CB6724")
  //  static let colorBackground = UIColor(hex: "#212121")
  //  static let colorBorder = UIColor(hex: "#424242")
  //  static let colorTitle =  UIColor(hex: "#fafafa")
  //  static let colorSubtitle = UIColor(hex: "#757575")
  //  static let colorStatusBar = UIBarStyle.BlackTranslucent
}



// MARK: - NAVIGATION
extension UINavigationController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    navigationBar.barStyle = Global.colorStatusBar
    navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationBar.backgroundColor = Global.colorBackground
    navigationBar.tintColor = Global.colorButton
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Global.colorTitle]
    toolbar.barTintColor = Global.colorBackground
    toolbar.backgroundColor = Global.colorBackground
    toolbar.tintColor = Global.colorButton
    Util.setStatusBarBackgroundColor(Global.colorBackground)
  }
}

extension UITabBarController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    tabBar.backgroundImage = UIImage()
    tabBar.backgroundColor = Global.colorBackground
    tabBar.tintColor = Global.colorButton
  }
}


// MARK: - TABLEVIEW
extension UITableViewController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
  }

  func configureTableView() {
    // color
    tableView.backgroundColor = Global.colorBackground

    // borders
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRect.zero)

    // refresh
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = Global.colorBorder
    refreshControl?.addTarget(self, action: #selector(UITableViewController.startRefresh), forControlEvents: .ValueChanged)
    edgesForExtendedLayout = .None
  }

  // refresh
  func startRefresh() {}

  func stopRefresh() {
    refreshControl?.endRefreshing()
  }
}


// MARK: - TABLEVIEW CELL
extension UITableViewCell {
  override public func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = Global.colorBackground
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    selectionStyle = .None
  }
}