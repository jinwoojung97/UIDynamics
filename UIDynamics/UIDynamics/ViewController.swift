//
//  ViewController.swift
//  UIDynamics
//
//  Created by inforex on 2022/11/07.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxGesture

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var boundaryView = UIView().then {
        $0.backgroundColor = .gray
    }
    
    var startButton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("start", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }
    
    var blueBoxView = UIView().then {
        $0.backgroundColor = .blue
    }
    var redBoxView = UIView().then{
        $0.backgroundColor = .red
    }
    
    // 다이나믹스 애니메이터 인스턴스 변수 선언
    var animator: UIDynamicAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addComponent()
        setConstraint()
        bind()
        
        // 다이나믹스 인스턴스 생성 초기화
        animator = UIDynamicAnimator(referenceView: boundaryView)
    }
    
    func addComponent(){
        [boundaryView, startButton].forEach(view.addSubview)
        [blueBoxView, redBoxView].forEach(boundaryView.addSubview)
    }
    
    func setConstraint(){
        startButton.snp.makeConstraints{
            $0.width.equalTo(100)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(50)
        }
        
        boundaryView.snp.makeConstraints{
            $0.width.equalToSuperview().dividedBy(2)
            $0.height.equalToSuperview().multipliedBy(0.6)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(150)
        }
        
        blueBoxView.snp.makeConstraints{
            $0.size.equalTo(80)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        
        redBoxView.snp.makeConstraints{
            $0.size.equalTo(50)
            $0.trailing.equalToSuperview().inset(110)
            $0.bottom.equalToSuperview()
        }
    }
    
    func reset(){
        [blueBoxView, redBoxView].forEach(boundaryView.addSubview)
        
        blueBoxView.snp.makeConstraints{
            $0.size.equalTo(80)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        
        redBoxView.snp.makeConstraints{
            $0.size.equalTo(50)
            $0.trailing.equalToSuperview().inset(110)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(){
        startButton.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.rise()
                self?.rotate()
            }.disposed(by: disposeBag)
        
        blueBoxView.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.blueBoxView.stopRotating()
                self?.blueBoxView.removeFromSuperview()
                print("blue tap")
            }.disposed(by: disposeBag)
        
        redBoxView.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.redBoxView.stopRotating()
                self?.redBoxView.removeFromSuperview()
                print("red tap")
            }.disposed(by: disposeBag)
    }
    
    func rise() {
        // 두 뷰에 대한 중력 설정
        let gravity = UIGravityBehavior(items: [blueBoxView, redBoxView])
        
        // y축 방향으로 1.0 UIkit Newton의 중력 설정. 음수 값으로 설정하면 중력의 반대 방향으로 간다.
        let vector = CGVector(dx: 0.0, dy: -0.1)
        gravity.gravityDirection = vector

//        animator?.addBehavior(gravity)
        
        // 충돌 설정
        let collision = UICollisionBehavior(items: [blueBoxView, redBoxView])
        // 설정된 경계와 충돌을 한다.
        collision.translatesReferenceBoundsIntoBoundary = true
        /**
         .items - 충돌 동작 인스턴스에 추가된 항목들만 충돌함
         .boundaries - 항목간 충돌 하지않고 경계에 대한 충돌만 인식
         .everything - 항목과 경계 모두 충돌
         **/
        collision.collisionMode = UICollisionBehavior.Mode.boundaries
        collision.collisionDelegate = self
        
//        animator?.addBehavior(collision)
        
        let bounce = UIDynamicItemBehavior(items: [blueBoxView, redBoxView])
        // 탄성 설정 값이 높을수록 높게 튀어오름
        bounce.elasticity = 0.2
        
        let customBehavior = UIDynamicBehavior()
        [gravity, collision, bounce].forEach(customBehavior.addChildBehavior)
        
        animator?.addBehavior(customBehavior)
    }
    
    func rotate(){
        blueBoxView.rotate()
        redBoxView.rotate()
    }
    
    func stopRotate(){
        blueBoxView.stopRotating()
        redBoxView.stopRotating()
    }
}

extension ViewController : UICollisionBehaviorDelegate {
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        print("began collision")
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        print("end collision")
    }
}



extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func rotate(duration: Double = 3) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            let randomNumber = Int.random(in: 0..<2)
            let direction: CGFloat = randomNumber == 0 ? -1.0 : 1.0
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = (.pi * 2.0) * direction
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}

