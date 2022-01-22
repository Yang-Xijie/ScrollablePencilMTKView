import UIKit

class MainVC: UIViewController {
    /// open document button at the center of the screen
    var openDocumentButton: UIButton!
    /// display a document editing UI
    var documentVC: DocumentVC!

    override func loadView() {
        view = {
            let v = UIView()
            v.backgroundColor = .white
            return v
        }()

        // MARK: openDocumentButton

        openDocumentButton = {
            let b = UIButton()
            b.setTitle("Open Test Document", for: .normal)
            b.setTitleColor(.systemBlue, for: .normal)
            b.addTarget(self, action: #selector(openTestDocument), for: .touchUpInside)
            return b
        }()
        view.addSubview(openDocumentButton)
        openDocumentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openDocumentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openDocumentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: navigation

        title = "Documents"
    }

    @objc func openTestDocument() {
        documentVC = DocumentVC()
        documentVC.modalPresentationStyle = .fullScreen
        present(documentVC, animated: true) {}
    }
}
