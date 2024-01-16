//
//  UIViewController+Ext.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/15/24.
//

import Foundation
import UIKit

protocol StoryBoarded {
    static func getInstance(_ storyboardName: String?, vcIdentifier: String?) -> Self
}

extension StoryBoarded where Self: UIViewController {
    static func getInstance(_ storyboardName: String? = nil, vcIdentifier: String? = nil) -> Self {
        let storyboard = UIStoryboard(name: storyboardName ?? String(describing: self), bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: vcIdentifier ?? String(describing: self)) as! Self
    }
}

extension UIViewController : StoryBoarded {}
