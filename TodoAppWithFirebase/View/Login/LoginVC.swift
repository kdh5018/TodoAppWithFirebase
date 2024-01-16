//
//  LoginVC.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/11/24.
//

import UIKit
import SnapKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var loginWithAppleButton: UIButton!
    @IBOutlet weak var loginWithKaKaoButton: UIButton!
    
    var viewModel = ViewModel()
    
    // 상단뷰
    lazy var aboveView = UIView()
    // 하단뷰
    lazy var belowView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI 설정
        setupUI()
        // 로그인 설정
        configureUI()
        
    }
    
    func setupUI() {
        // 1. 상단 뷰
        self.view.addSubview(aboveView)
        aboveView.backgroundColor = .systemBlue
        aboveView.layer.shadowColor = UIColor.black.cgColor
        aboveView.layer.shadowOpacity = 1
        aboveView.layer.shadowOffset = CGSize(width: 2, height: 2)
        aboveView.layer.shadowRadius = 4
        aboveView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(-750)
            make.right.equalTo(self.view).offset(0)
            
        }
        
        // 2. 하단 뷰
        self.view.addSubview(belowView)
        // 버튼 보이게끔 하기 위해 뒤로 보냄
        self.view.sendSubviewToBack(belowView)
        belowView.backgroundColor = .yellow
        belowView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(50)
            make.top.equalTo(aboveView).offset(104)
            make.left.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(-0)
            make.right.equalTo(self.view).offset(0)
        }
        
    }
    
    // MARK: - UI
    private func configureUI() {
        loginWithAppleButton.addTarget(self, action: #selector(loginWithAppleButtonTapped), for: .touchUpInside)
        loginWithKaKaoButton.addTarget(self, action: #selector(loginWithKaKaoButtonTapped), for: .touchUpInside)
    }
    
    @objc func loginWithAppleButtonTapped() {
        print(#fileID, #function, #line, "- 애플 로그인")
        AuthManager.shared.startSignInWithAppleFlow(presentingVC: self, completion: { (uid: String?, error: Error?) in
            self.handleUserLoggedInEvent(uid)
        })
    }
    
    @objc func loginWithKaKaoButtonTapped() {
        print(#fileID, #function, #line, "- 카카오 로그인")
        AuthManager.shared.startKakaoFirebaseLoginFlow(completion: {(uid: String?, error: Error?) in
            self.handleUserLoggedInEvent(uid)
        })
    }
    
    fileprivate func handleUserLoggedInEvent(_ uid: String?) {
        if let uid = uid {
            UserDefaults.standard.setValue(uid, forKey: "uid")
            self.navigationController?.pushViewController(MainVC.getInstance(), animated: true)
            
        }
    }
    
}
