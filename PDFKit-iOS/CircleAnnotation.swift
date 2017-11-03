//
//  CircleAnnotation.swift
//  PDFKit-iOS
//
//  Created by Parth Adroja on 17/07/17.
//  Copyright © 2017 Solution Analysts. All rights reserved.
//

import UIKit

class CircleAnnotation: UIView {

    var uuid: String?
    var page: Int?
    var by_id: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawCircle(container: rect)
    }
    
    func drawCircle(container: CGRect = CGRect(x: 0, y: 50, width: 50, height: 50)) {
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: container.minX, y: container.minY, width: container.width, height: container.height))
        UIColor.gray.setFill()
        ovalPath.fill()
    }
}
