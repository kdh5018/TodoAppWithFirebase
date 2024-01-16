//
//  SplashVC.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/15/24.
//

import Foundation
import UIKit

class SplashVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 저장된 uid 체크
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            self.navigationController?.pushViewController(MainVC.getInstance(), animated: true)
        } else {
            self.navigationController?.pushViewController(LoginVC.getInstance(), animated: true)
        }
        
    }
    
}
