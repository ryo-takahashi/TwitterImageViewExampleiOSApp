import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var openImageViewButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
}

extension ViewController {
    private func setupViewController() {
        openImageViewButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentTwitterSwipeImageViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func presentTwitterSwipeImageViewController() {
        let viewController = TwitterSwipeImageViewController()
        // 👇overCurrentContextを指定しないと、ViewControllerの背景が透過しない
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController?.present(viewController, animated: false, completion: nil)
    }
    
}

