//
//  ExampleAuthManager.swift
//  TLSModules_Example
//
//  Created by Justin Ji on 29/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import TLSModules

class ExampleAuthManager: AuthManager<ExampleAuthUser> {
    
    public var policies = [Policy]()
    public var verificationType: AuthVerificationType = .email
    private var user: ExampleAuthUser?
    private var email: String?
    
    override func execute(completionHandler completion: ((ExampleAuthUser) -> Void)?) {
        
        let authPolicyVC = AuthPolicyListViewController()
        authPolicyVC.policies = self.policies
        authPolicyVC.completeAction = { [unowned self] in
            self.goToEmailVerification(completionHandler: completion)
        }
        vc.navigationController?.pushViewController(authPolicyVC, animated: true)
    }
    
    public func findPw(completionHandler completion: ((String) -> Void)?) {
        let authVerificationVC = AuthVerificationViewController()
        authVerificationVC.verificationType = .email
        authVerificationVC.verificationGoalType = .reset
        authVerificationVC.completeAction = { [unowned self] pw in
            Logger.showDebuggingMessage(pw)
        }
        
        authVerificationVC.sendAction = { input in
            let type = authVerificationVC.verificationType == .email ? 0 : 1
            let request = ExampleRequest.verification(body: ["email": input, "type": type])
            RequestManager.request(with: request, completionHandler: { (result) in
                RequestManager.evaluate(by: result, { (json) in
                    authVerificationVC.handleVCodeSent(by: true)
                }, { (_) in
                    authVerificationVC.handleVCodeSent(by: false)
                })
            })
        }
        
        vc.navigationController?.pushViewController(authVerificationVC, animated: true)
    }
    
    private func goToEmailVerification(completionHandler completion: ((ExampleAuthUser) -> Void)?) {
        let authVerificationVC = AuthVerificationViewController()
        authVerificationVC.verificationType = self.verificationType
        authVerificationVC.completeAction = { [unowned self] email in
            self.goToPassword(with: email, completionHandler: completion)
            Logger.showDebuggingMessage(email)
        }
        
        authVerificationVC.sendAction = { input in
            let type = authVerificationVC.verificationType == .email ? 0 : 1
            let request = ExampleRequest.verification(body: ["email": input, "type": type])
            RequestManager.request(with: request, completionHandler: { (result) in
                RequestManager.evaluate(by: result, { (json) in
                    authVerificationVC.handleVCodeSent(by: true)
                }, { (_) in
                    authVerificationVC.handleVCodeSent(by: false)
                })
            })
        }
        
        vc.navigationController?.pushViewController(authVerificationVC, animated: true)
    }

    private func goToPassword(with email: String, completionHandler completion: ((ExampleAuthUser) -> Void)?) {
        let passwordVC = PasswordViewController()
        passwordVC.goalType = .register
        passwordVC.completeAction = { pw in
            Logger.showDebuggingMessage(pw)
            let user = ExampleAuthUser(email: email, mobile: nil, password: pw)
            completion?(user)
        }
        vc.navigationController?.pushViewController(passwordVC, animated: true)
    }
}