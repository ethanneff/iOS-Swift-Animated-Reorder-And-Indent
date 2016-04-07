//
//  DataProtocols.swift
//  NotesApp
//
//  Created by Ethan Neff on 4/4/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

protocol DataIndentable {
  var indent: Int { get set }
}

protocol DataTagable {
  var tags: [Tag] { get set }
}

protocol DataCollapsible {
  var collapsed: Bool { get set }
  var children: Int { get set }
}

protocol DataCompleteable {
  var completed: Bool { get set }
}