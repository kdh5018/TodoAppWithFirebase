//
//  LoginVC.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/11/24.
//

import UIKit
import FirebaseAuth
import SnapKit
import AuthenticationServices
import CryptoKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var loginWithAppleButton: UIButton!
    

    var currentNonce: String?
    
    var viewModel = ViewModel()
    
    // 상단뷰
    lazy var aboveView = UIView()
    // 하단뷰
    lazy var belowView = UIView()
    
    // 제공받은 id의 도메인 추출을 위한 변수
    var providerID: String?
    
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
    }
    
    @objc func loginWithAppleButtonTapped() {
        print(#fileID, #function, #line, "- 애플 로그인")
        startSignInWithAppleFlow()
    }
    
    
}
//MARK: - 애플 로그인
extension LoginVC {
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    /// 애플 로그인 Flow
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
}

extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

extension LoginVC: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                        rawNonce: nonce,
                                                        fullName: appleIDCredential.fullName)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
          if (error != nil) {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
              print(error?.localizedDescription)
          return
        }
        // User is signed in to Firebase with Apple.
        // ...
          print(#fileID, #function, #line, "- 애플 로그인 성공")
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
