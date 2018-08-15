import UIKit
import RxSwift
import RxCocoa

class TwitterSwipeImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClosePanGesture()
    }
}

extension TwitterSwipeImageViewController {
    
    enum CloseDirection {
        case up
        case down
    }
    
    private func setupClosePanGesture() {
        var startPanPointY: CGFloat = 0.0
        var distanceY: CGFloat = 0.0
        let moveAmountYCloseLine: CGFloat = view.bounds.height / 6
        let minBackgroundAlpha: CGFloat = 0.5
        let maxBackgroundAlpha: CGFloat = 1.0
        
        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        panGesture.rx.event
            .subscribe(onNext: { [weak self] sender in
                guard let strongSelf = self else { return }
                
                let currentPointY = sender.location(in: strongSelf.view).y
                
                switch sender.state {
                case .began:
                    startPanPointY = currentPointY
                    distanceY = strongSelf.imageView.center.y - startPanPointY
                    strongSelf.updateHeaderFooterView(isHidden: true)
                case .changed:
                    let calcedImageViewPosition = CGPoint(x: strongSelf.view.bounds.width / 2, y: distanceY + currentPointY)
                    strongSelf.imageView.center = calcedImageViewPosition
                    
                    let moveAmountY = fabs(currentPointY - startPanPointY)
                    var backgroundAlpha = moveAmountY / (-moveAmountYCloseLine) + 1
                    if backgroundAlpha > maxBackgroundAlpha {
                        backgroundAlpha = maxBackgroundAlpha
                    } else if backgroundAlpha < minBackgroundAlpha {
                        backgroundAlpha = minBackgroundAlpha
                    }
                    strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(backgroundAlpha)
                case .ended:
                    let moveAmountY = currentPointY - startPanPointY
                    let isCloseTop = moveAmountY > moveAmountYCloseLine
                    let isCloseBottom = moveAmountY < moveAmountYCloseLine * -1
                    if isCloseTop {
                        strongSelf.dismiss(animateDuration: 0.15, direction: .up)
                        return
                    }
                    if isCloseBottom {
                        strongSelf.dismiss(animateDuration: 0.15, direction: .down)
                        return
                    }
                    UIView.animate(withDuration: 0.25, animations: {
                        strongSelf.imageView.center = strongSelf.view.center
                        strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(1.0)
                    })
                    strongSelf.updateHeaderFooterView(isHidden: false)
                default: break
                }
            })
            .disposed(by: disposeBag)
        self.view.addGestureRecognizer(panGesture)
    }
    
    
    private func dismiss(animateDuration: TimeInterval, direction: CloseDirection) {
        let imageViewCenterPoint: CGPoint = {
            switch direction {
            case .up:
                return CGPoint(x: view.bounds.width / 2, y: view.bounds.height + imageView.bounds.height)
            case .down:
                return CGPoint(x: view.bounds.width / 2, y: -imageView.bounds.height)
            }
        }()
        UIView.animate(withDuration: animateDuration, animations: { [weak self] in
            self?.view.backgroundColor = self?.view.backgroundColor?.withAlphaComponent(0.0)
            self?.imageView.center = imageViewCenterPoint
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: nil)
        })
    }
    
    // Twitterでいう、「リプライ」「お気に入り」などがあるViewの表示制御処理
    private func updateHeaderFooterView(isHidden: Bool) {
        print("isHidden = \(isHidden)")
    }
}
