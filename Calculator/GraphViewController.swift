//
//  GraphViewController.swift
//  Calculator
//
//  Created b/Users/ziliangzhu/Developer/Calculator/Calculator/GraphViewController.swifty Ziliang Zhu on 9/20/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//


import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "move:"))
            let tapGesture = UITapGestureRecognizer(target: graphView, action: "teleport:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGesture)
            graphView.dataSource = self
        }
    }
    
    private var functionToDraw: (Double -> Double)? {
        didSet {
            title = "test"
        }
    }
    
    func functionToDraw(sender: GraphView) -> (Double -> Double)? {
        return functionToDraw
    }
    
    func setFunctionToDraw(function: (Double -> Double)?) {
        functionToDraw = function
    }
    
    func showFunction(title: String) {
        super.title = title
    }
}

