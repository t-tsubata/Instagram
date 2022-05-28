//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/17.
//

import UIKit
import Firebase
import FirebaseStorageUI

class PostTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentStackView: UIStackView!
    
    // MARK: - Public
    var commentLabels: [UILabel] = []
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.commentLabels.forEach { $0.removeFromSuperview() }
        self.commentLabels.removeAll()
    }
    
    // MARK: - PublicMethods
    /// PostDataの内容をセルに表示
    ///
    /// - Parameter postData: PostData
    func setPostData(_ postData: PostData) {
        // 画像の表示
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        self.postImageView.sd_setImage(with: imageRef)
        
        // キャプションの表示
        if let name = postData.name, let caption = postData.caption {
            self.captionLabel.text = "\(name) : \(caption)"
        }
        
        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        self.likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメント数を表示
        let commentNumber = postData.comments.count
        self.commentNumberLabel.text = "\(commentNumber)"
        
        // コメントを表示
        for commentIndex in 0..<commentNumber {
            let commentLabel = UILabel()
            if let commenter = postData.comments[commentIndex]["commenter"],
               let content = postData.comments[commentIndex]["content"] {
                commentLabel.text = "\(commenter) \(content)"
            }
            self.commentStackView.addArrangedSubview(commentLabel)
            self.commentLabels.append(commentLabel)
        }
    }
}
