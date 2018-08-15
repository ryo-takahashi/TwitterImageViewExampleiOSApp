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
    private func setupClosePanGesture() {
        var startPanPointY: CGFloat = 0.0
        var distanceY: CGFloat = 0.0
        let moveAmountYCloseLine: CGFloat = view.bounds.height / 6
        let backgroundAlphaCalcStandardValue: CGFloat = view.bounds.height / 6
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
                    let calcedPosition = CGPoint(x: strongSelf.view.bounds.width / 2, y: distanceY + currentPointY)
                    strongSelf.imageView.center = calcedPosition
                    
                    let moveAmountY = fabs(currentPointY - startPanPointY)
                    var calcBackgroundAlphaValue = moveAmountY / backgroundAlphaCalcStandardValue * -1 + 1
                    if calcBackgroundAlphaValue > maxBackgroundAlpha {
                        calcBackgroundAlphaValue = maxBackgroundAlpha
                    } else if calcBackgroundAlphaValue < minBackgroundAlpha {
                        calcBackgroundAlphaValue = minBackgroundAlpha
                    }
                    strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(calcBackgroundAlphaValue)
                case .ended:
                    let moveAmountY = currentPointY - startPanPointY
                    if moveAmountY > moveAmountYCloseLine {
                        UIView.animate(withDuration: 0.125, animations: {
                            strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(0.0)
                            strongSelf.imageView.center = CGPoint(x: strongSelf.view.bounds.width / 2, y: strongSelf.view.bounds.height + strongSelf.imageView.bounds.height)
                        }, completion: { _ in
                            strongSelf.dismiss(animated: false, completion: nil)
                        })
                    } else if moveAmountY < moveAmountYCloseLine * -1 {
                        UIView.animate(withDuration: 0.125, animations: {
                            strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(0.0)
                            strongSelf.imageView.center = CGPoint(x: strongSelf.view.bounds.width / 2, y: -strongSelf.imageView.bounds.height)
                        }, completion: { _ in
                            strongSelf.dismiss(animated: false, completion: nil)
                        })
                    } else {
                        UIView.animate(withDuration: 0.25, animations: {
                            strongSelf.imageView.center = strongSelf.view.center
                            strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(1.0)
                        })
                        strongSelf.updateHeaderFooterView(isHidden: false)
                    }
                default: break
                }
            })
            .disposed(by: disposeBag)
        self.view.addGestureRecognizer(panGesture)
    }
    
    
    // Twitterでいう、「リプライ」「お気に入り」などがあるViewの表示制御処理
    private func updateHeaderFooterView(isHidden: Bool) {
        print("isHidden = \(isHidden)")
    }
}
