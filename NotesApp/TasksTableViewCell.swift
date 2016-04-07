//
//  TasksTableViewCell.swift
//  NotesApp
//
//  Created by Ethan Neff on 4/2/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TasksTableViewCell: SwipeCell {
  // PROPERTIES
  static let height: CGFloat = 34
  static let identifier: String = "cell"
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var accessoryButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func renderData(data data: Task) {
    // indent
    var indent = ""
    for _ in 0..<data.indent {
      indent += "     "
    }
    let title = indent + data.title
    // complete
    if data.completed {
      let attrString = NSAttributedString(string: title, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
      titleLabel.attributedText = attrString
      titleLabel.textColor = Global.colorBorder
      accessoryButton.tintColor = Global.colorBorder
    } else {
      titleLabel.textColor = Global.colorTitle
      accessoryButton.tintColor = Global.colorButton
      titleLabel.text = title
    }

    // accessory icon
    let accessoryTitle = data.collapsed ? String(data.children) : "+"
    accessoryButton.setTitle(accessoryTitle, forState: UIControlState.Normal)
  }
}