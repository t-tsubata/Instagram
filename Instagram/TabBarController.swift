//
//  TabBarController.swift
//  Instagram
//
//  Created by 津端 俊尚 on 2022/05/13.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        self.tabBar.standardAppearance = appearance
        
        // iOSのバージョンが15以上の場合、scrollEdgeAppearanceを設定
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        }
        
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    
    /// タブバーのアイコンがタップされたときに呼ばれるdelegateメソッドを処理
    ///
    /// - Parameters:
    ///   - tabBarController: UItabBarControlle
    ///   - viewController: UIViewController
    /// - Returns: 通常のタブ切り替えかどうか
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerはタブの切り替えではなくモーダル画面遷移
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
            present(imageSelectViewController, animated: true)
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
    }
}
