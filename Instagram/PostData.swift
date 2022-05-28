//
//  PostData.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/17.
//

import UIKit
import Firebase

class PostData: NSObject {
    
    // MARK: - Public
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var comments: [[String:String]] = []
    
    // MARK: - PublicMethods
    /// プロパティーの初期化
    ///
    /// - Parameter document: Firestoreから取得したドキュメント
    init(document: QueryDocumentSnapshot) {
        let postDic = document.data()
        let timestamp = postDic["date"] as? Timestamp
        
        self.id = document.documentID
        self.name = postDic["name"] as? String
        self.caption = postDic["caption"] as? String
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let comments = postDic["comments"] as? [[String:String]] {
            self.comments = comments
        }
        if let myid = Auth.auth().currentUser?.uid {
            // lilesの配列の中にmyidが含まれているかをチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識
                self.isLiked = true
            }
        }
    }
}
