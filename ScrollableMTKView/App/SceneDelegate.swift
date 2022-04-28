import UIKit
import XCLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var mainVC: MainVC!

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        mainVC = MainVC()
        window!.rootViewController = UINavigationController(rootViewController: mainVC)
        window!.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        XCLog(.trace)
//        mainVC.documentVC?.renderView.isPaused = true
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        XCLog(.trace)
//        mainVC.documentVC?.loadView() // FIXME: 会增加内存！！！ // TODO: 保存在进入前的位置信息 使用该信息loadView即可
//        mainVC.documentVC?.renderView.isPaused = false
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        XCLog(.trace)
        // TODO:
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        XCLog(.trace)
        // TODO:
    }

    func sceneDidDisconnect(_ scene: UIScene) { XCLog(.trace) }
}
