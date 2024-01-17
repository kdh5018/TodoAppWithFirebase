//
//  AuthManager.swift
//  TodoAppWithFirebase
//
//  Created by 김도훈 on 1/15/24.
//

import Foundation
import UIKit

// firebase
import FirebaseCore
import FirebaseAuth

// apple login
import CryptoKit
import AuthenticationServices

// Kakao Login
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

final class AuthManager : NSObject {
    static let shared = AuthManager()
    
    //MARK: - 애플로그인 프로퍼티들
    // Unhashed nonce.
    fileprivate var currentNonce: String? = nil
    weak var applePresentingVC: UIViewController? = nil
    var appleLoginCompletion : ((_ uid: String?, Error?) -> Void)? = nil
    // ======== 애플로그인 프로퍼티들 ========
    
    /// 카카오톡 로그인 시작
    func startKakaoFirebaseLoginFlow(completion: @escaping (_ uid: String?, Error?) -> Void){
        print(#fileID, #function, #line, "- ")
        
        
        /// 카카오 로그인 하고 OpenID 토큰 가져오기
        func fetchKakaoOpenIDToken(completion: @escaping (String?, Error?) -> Void){
            // 카카오톡 실행 가능 여부 확인
            // 카카오톡이 설치되어 있다면
            if (UserApi.isKakaoTalkLoginAvailable()) {
                // 카카오톡으로 로그인
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    if let error = error {
                        print(error)
                        completion(nil, error)
                        return
                    }
                    else {
                        print("loginWithKakaoTalk() success.")
                        
                        //do something
                        _ = oauthToken
                        completion(oauthToken?.idToken, nil)
                    }
                }
            } else {
                // 웹 브라우저로 로그인 시도
                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                        completion(nil, error)
                        return
                    }
                    else {
                        print("loginWithKakaoAccount() success.")
                        
                        //do something
                        _ = oauthToken
                        completion(oauthToken?.idToken, nil)
                    }
                }
            }
        } // fetchKakaoOpenIDToken
        
        
        fetchKakaoOpenIDToken(completion: { idToken, error in
            
            guard let idToken = idToken else {
                completion(nil, error)
                return }
            
            let credential = OAuthProvider.credential(
                withProviderID: "oidc.kakao",  // As registered in Firebase console.
                idToken: idToken,  // ID token from OpenID Connect flow.
                rawNonce: nil
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    // Handle error.
                    print(#fileID, #function, #line, "- 에러 \(error)")
                    completion(nil, error)
                    return
                }
                // User is signed in.
                // IdP data available in authResult?.additionalUserInfo?.profile
                let uid = authResult?.user.uid
                print(#fileID, #function, #line, "- 카카오 로그인 성공 : \(authResult)")
                completion(uid, nil)
            }
            
        })
        
    } // startKakaoFirebaseLoginFlow
    
    
    
    /// 애플로그인 플로우
    /// 클로져 부분 이해가 안되시면 아래 영상 참고해보세요
    /// https://youtube.com/playlist?list=PLgOlaPUIbynpWid21CVyZbAUiaRRXzqdE&si=BkIYCQ3sS-qGLagk
    func startSignInWithAppleFlow(presentingVC: UIViewController,
                                  completion: @escaping (_ uid: String?, Error?) -> Void) {
        
        func randomNonceString(length: Int = 32) -> String {
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
        } // randomNonceString
        
        @available(iOS 13, *)
        func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                String(format: "%02x", $0)
            }.joined()
            
            return hashString
        }
        
        self.appleLoginCompletion = completion
        self.applePresentingVC = presentingVC
        
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
    } // startSignInWithAppleFlow
    
    
}


extension AuthManager : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return applePresentingVC!.view.window!
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                appleLoginCompletion?(nil, nil)
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                appleLoginCompletion?(nil, nil)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                appleLoginCompletion?(nil, nil)
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription)
                    self.appleLoginCompletion?(nil, error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                let uid = authResult?.user.uid
                print(#fileID, #function, #line, "- 애플 로그인 성공")
                self.appleLoginCompletion?(uid, nil)
            }
        }
    } // authorizationController
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
