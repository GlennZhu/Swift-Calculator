//
//  GraphView.swift
//  Calculator
//
//  Created by Ziliang Zhu on 9/20/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func functionToDraw(sender: GraphView) -> (Double -> Double)?
}

@IBDesignable
class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var scale: CGFloat = 1.0 {
        didSet {
            if scale <= 0 {
                scale = 1
            }
            setNeedsDisplay()
        }
    }
    
    var origin: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var center : CGPoint {
        didSet {
            origin = center
        }
    }
    
    private let drawer: AxesDrawer = AxesDrawer(contentScaleFactor: 1)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        drawer.drawInRect(rect, origin: origin, pointsPerUnit: scale, functionToDraw: dataSource?.functionToDraw(self))
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed {
            let translation = gesture.translationInView(self)
            origin.x += translation.x
            origin.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        }
    }
    
    func teleport(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
            println(origin)
        }
    }
}
