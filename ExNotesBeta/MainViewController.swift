import UIKit

class MainViewController: UIViewController {
    var openDocButton: UIButton!
    var scrollablePencilMTKViewController: ScrollableMTKViewController!

    override func loadView() {
        view = {
            let v = UIView()
            v.backgroundColor = .white
            return v
        }()

        openDocButton = {
            let b = UIButton()

            b.setTitle("Open Test Document", for: .normal)
            b.setTitleColor(.systemBlue, for: .normal)
            b.addTarget(self, action: #selector(openTestDocument), for: .touchUpInside)
            return b
        }()
        view.addSubview(openDocButton)

        openDocButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openDocButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openDocButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Documents"
    }

    @objc func openTestDocument() {
        scrollablePencilMTKViewController = ScrollableMTKViewController()
        scrollablePencilMTKViewController.modalPresentationStyle = .fullScreen
        present(scrollablePencilMTKViewController, animated: true) {}
    }
}
