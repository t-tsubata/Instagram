//
//  PostViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    // MARK: - Public
    var image: UIImage!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 受け取った画像をImageViewに設定
        self.imageView.image = self.image
    }
    
    // MARK: - PrivateMethods
    /// 投稿ボタンをタップしたときに呼ばれる
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handlePostButton(_ sender: Any) {
        // 画像をJPEG形式に変換
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        // 画像と投稿データの保存場所を定義
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        // HUDで投稿中の表示を開始
        SVProgressHUD.show()
        // Storageに画像をアップロード
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error{
                // 画像のアップロード失敗
                print(error)
                SVProgressHUD.showError(withStatus: "画像のアップロードに失敗しました。")
                // 投稿処理をキャンセルし、先頭画面に戻る
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            // FireStoreに投稿データを保存
            if let name = Auth.auth().currentUser?.displayName, let caption = self.captionTextField.text {
                let postDic = [
                    "name": name,
                    "caption": caption,
                    "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
                postRef.setData(postDic)
            }
            // HUDで投稿完了を表示
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            // 投稿処理が完了したので先頭画面に戻る
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// キャンセルボタンをタップしたときに呼ばれる
    /// 
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
}
