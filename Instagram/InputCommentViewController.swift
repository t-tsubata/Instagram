//
//  CommentViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/18.
//

import UIKit
import Firebase
import SVProgressHUD

class InputCommentViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var commentTextField: UITextField!
    
    // MARK: - Public
    var postData: PostData?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - PrivateMethods
    /// 投稿ボタンをタップしたときに呼ばれる
    ///
    /// - Parameter sender: トリガーとなったボタン
    @IBAction private func tapPostButton(_ sender: Any) {
        // HUDで投稿中の表示を開始
        SVProgressHUD.show()
        
        // commentsを更新
        if let displayName = Auth.auth().currentUser?.displayName, let content = self.commentTextField.text {
            let comment = ["commenter": displayName, "content":content]
            var comments: FieldValue
            comments = FieldValue.arrayUnion([comment])
            
            // commentsに更新データを書き込む
            if let postData = self.postData {
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["comments": comments])
            }
        }
        
        // HUDで投稿完了を表示
        SVProgressHUD.showSuccess(withStatus: "コメントしました")
        // 投稿処理が完了したので先頭画面に戻る
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    /// キャンセルボタンを押したときに呼ばれる
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func tapCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    /// キーボードを閉じる
    @objc private func dismissKeyBoard() {
        self.view.endEditing(true)
    }
}
