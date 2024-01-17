//
//  Reuseidentifier.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/17/24.
//

import Foundation
import UIKit


protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }
