//
//  LoginViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import Firebase
import grpc
import SVProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // MARK: - Private
    private var auth: Auth?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.auth = Auth.auth()
    }
    
    // MARK: - PrivateMethods
    ///  ログインボタンをタップしたときに呼ばれるメソッド
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleLoginButton(_ sender: Any) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {
            // アドレスとパスワードのいずれかでも入力されていないときは何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力してください。")
                return
            }
            
            // HUVで処理中を表示
            SVProgressHUD.show()
            
            self.auth?.signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    ///  アカウント作成ボタンをタップしたときに呼ばれるメソッド
    ///  
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleCreateAccountButton(_ sender: Any) {
        if let address = self.mailAddressTextField.text,
           let password = self.passwordTextField.text,
           let displayName = self.displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていないときは何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                return
            }
        
            // アドレスとパスワードでユーザー作成
            // ユーザー作成に成功すると、自動的にログイン
            self.auth?.createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    // エラーがあったら原因をprintして、
                    // returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィール更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        
                        if let displayName = user.displayName {
                            print("DEBUG_PRINT: [displayName = \(displayName)]の設定に成功しました。")
                        }
                        
                        // HUVを消す
                        SVProgressHUD.dismiss()
                        
                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
