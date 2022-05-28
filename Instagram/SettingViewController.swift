//
//  SettingViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var displayNameTextField: UITextField!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            self.displayNameTextField.text = user.displayName
        }
    }
    
    // MARK: - PrivateMethods
    /// 表示名変更ボタンをタップしたときに呼ばれる
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleChangeButton(_ sender: Any) {
        if let displayName = self.displayNameTextField.text {
            // 表示名が入力されていないときはHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力してください。")
                return
            }
            
            // 表示名を設定
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges() { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    
                    if let displayName = user.displayName {
                        print("DEBUG_PRINT: [displayName = \(displayName)]の設定に成功しました。")
                    }
                    
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました。")
                }
            }
        }
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    /// ログアウトボタンをタップしたときに呼ばれる
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try? Auth.auth().signOut()
        
        // ログイン画面を表示
        if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
            self.present(loginViewController, animated: true, completion: nil)
        }
       
        // ログイン画面から戻ってきたときのためにホーム画面(index = 0)を選択している状態にする
        self.tabBarController?.selectedIndex = 0
    }
}
