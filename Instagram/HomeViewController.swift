//
//  HomeViewController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private
    private let postPath: CollectionReference = Firestore.firestore().collection(Const.PostPath)
    private var postArray: [PostData] = []
    private var listener: ListenerRegistration?
    private var currentUser: User?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // カスタムセルを登録
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        self.currentUser = Auth.auth().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if self.currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = self.postPath.order(by: "date", descending: true)
            self.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                if let querySnapshot = querySnapshot {
                    self.postArray = querySnapshot.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止
        self.listener?.remove()
    }
    
    // MARK: - PrivateMethods
    
    /// いいねボタンがタップされたときに呼ばれる
    ///
    /// - Parameters:
    ///   - sender: トリガーとなったボタン
    ///   - event: イベント処理
    @objc private func handleLikeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        guard let point = touch?.location(in: self.tableView),
              let indexPath = self.tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath.row]
        
        // likesを更新
        if let myid = self.currentUser?.uid {
            // 更新データを作成
            var updateValue: FieldValue
            if postData.isLiked {
                // 既にいいねを押している場合の処理
                // いいね解除のため、myidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合の処理
                // myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = self.postPath.document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    /// コメントボタンがタップされたときに呼ばれる
    ///
    /// - Parameters:
    ///   - sender: トリガーとなったボタン
    ///   - event: イベント処理
    @objc private func handleCommentedButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: commentボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        guard let point = touch?.location(in: self.tableView),
              let indexpath = self.tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        // TODO: 強制アンラップ
        let postData = self.postArray[indexpath.row]
        
        let inputCommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "InputComment") as! InputCommentViewController
        inputCommentViewController.postData = postData
        self.present(inputCommentViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// セルの数を返す
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: セクション番号
    /// - Returns: セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }
    
    /// 各セルの内容を返す
    ///
    /// - Parameters:
    ///   - tableView: tableviewのインスタンス
    ///   - indexPath: 対象セルのセクションとインデックス
    /// - Returns: セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(self.postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定
        cell.likeButton.addTarget(self, action: #selector(self.handleLikeButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(self.handleCommentedButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
}
