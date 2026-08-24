//
//  TooltipBalloonView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit

// 본체: figma 사양 (145×40, padding 16/10, corner 8, bg white, text Body1.SemiBold text02)
// tail: 위쪽 작은 삼각형 (figma엔 없지만 디자인 시안에 따라 어디를 가리키는지 명확히 하기 위해 추가)
// 본체 + tail을 하나의 UIBezierPath로 합쳐 CAShapeLayer로 그린다.
// 동일 path를 layer.shadowPath에 재사용해 그림자도 모양 그대로 따라가게.
final class TooltipBalloonView: UIView {

    // MARK: - Style
    private let tailHeight: CGFloat = 6
    private let tailWidth: CGFloat = 12
    private let cornerRadius: CGFloat = 8
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 10

    // tail 가로 위치 (말풍선 좌표 기준). nil이면 중앙.
    var tailCenterX: CGFloat? {
        didSet { setNeedsLayout() }
    }

    // MARK: - Subviews
    private let shapeLayer = CAShapeLayer()

    private let label: UILabel = {
        let lb = UILabel()
        lb.font = FontStyle.Body1.semiBold
        lb.textColor = .text02
        lb.numberOfLines = 0
        return lb
    }()

    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        setupLayer()
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayer() {
        shapeLayer.fillColor = UIColor.bgPrimary.cgColor
        layer.insertSublayer(shapeLayer, at: 0)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }

    private func setupLabel() {
        addSubview(label)
        label.snp.makeConstraints { make in
            // 본체 영역(tail 아래)에 padding 적용
            make.top.equalToSuperview().offset(tailHeight + verticalPadding)
            make.bottom.equalToSuperview().offset(-verticalPadding)
            make.leading.equalToSuperview().offset(horizontalPadding)
            make.trailing.equalToSuperview().offset(-horizontalPadding)
        }
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShapePath()
    }

    private func updateShapePath() {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > tailHeight else { return }

        // 본체: tail 아래 영역의 둥근 사각형
        let bodyRect = CGRect(x: 0, y: tailHeight, width: w, height: h - tailHeight)
        let path = UIBezierPath(roundedRect: bodyRect, cornerRadius: cornerRadius)

        // tail: 위쪽 정점, 밑변은 본체 상단에 닿음
        let cx = tailCenterX ?? (w / 2)
        let tail = UIBezierPath()
        tail.move(to: CGPoint(x: cx - tailWidth / 2, y: tailHeight))
        tail.addLine(to: CGPoint(x: cx, y: 0))
        tail.addLine(to: CGPoint(x: cx + tailWidth / 2, y: tailHeight))
        tail.close()

        path.append(tail)

        shapeLayer.path = path.cgPath
        layer.shadowPath = path.cgPath
    }
}
