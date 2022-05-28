//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Private
    private let pickerController = UIImagePickerController()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - PrivateMethods
    /// ライブラリボタンを押したときの処理
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleLibraryButton(_ sender: Any) {
        // ライブラリ(カメラロール)を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.pickerController.delegate = self
            self.pickerController.sourceType = .photoLibrary
            self.present(self.pickerController, animated: true, completion: nil)
        }
    }
    
    /// カメラボタンを押したときの処理
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.pickerController.delegate = self
            self.pickerController.sourceType = .camera
            self.present(self.pickerController, animated: true, completion: nil)
        }
    }

    /// キャンセルボタンを押したときの処理
    ///
    /// - Parameter sender: トリガーとなったUI
    @IBAction private func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ImageSelectViewController: UIImagePickerControllerDelegate {
        
    /// 写真を撮影/選択したときに呼ばれる
    /// 
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: メディア情報
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerControllerを閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理
        if info[.originalImage] != nil {
            // 撮影/選択された画像の取得
            let image = info[.originalImage] as! UIImage
            
            // CLImageEditorライブラリで加工
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動
            if let editor = CLImageEditor(image: image) {
                editor.delegate = self
                self.present(editor, animated: true, completion: nil)
            }
        }
    }
    
    
    /// 写真加工画面でキャンセルボタンを押したときの処理
    ///
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerControllerを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CLImageEditorDelegate

extension ImageSelectViewController: CLImageEditorDelegate {
    
    /// CLImageEditorで加工が終わったときに呼ばれる
    ///
    /// - Parameters:
    ///   - editor: CLImageEditor
    ///   - image: 編集が終わった画像
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        if let image = image {
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
            postViewController.image = image
            editor.present(postViewController, animated: true, completion: nil)
        }
    }
    
    /// CLImageEditorの編集がキャンセルされたときに呼ばれる
    ///
    /// - Parameter editor: CLImageEditor
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // ImageEditor画面を閉じる
        editor.dismiss(animated: true, completion: nil)
    }
}
