//
//  PlatformColor.swift
//  Orb
//
//  Created by Peter Salz on 12.11.24.
//

#if canImport(UIKit)
import UIKit

typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit

typealias PlatformColor = NSColor
#endif
