//
//  ViewController.swift
//  Calculator
//
//  Created by Ziliang Zhu on 8/30/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    private var stack = Array<Double>()
    
    private var pressedEnter = false
    
    var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        set {
            display.text = "\(newValue)"
        }
    }
    
    @IBAction func pressNumber(sender: UIButton) {
        let pressedNumber = (sender.currentTitle! as NSString).doubleValue
    
        if pressedEnter {
            displayValue = 0
            pressedEnter = false
        }
        displayValue = displayValue * 10 + pressedNumber
    }
    
    @IBAction func pressEnter() {
        stack.append(displayValue)
        pressedEnter = true
        println(stack)
    }
    
    @IBAction func pressBinaryOp(sender: UIButton) {
        if !pressedEnter {
            pressEnter()
        }
        if (stack.count >= 2) {
            let thisBinaryOp = sender.currentTitle!
            let itemLate = stack.removeLast()
            let itemEarly = stack.removeLast()
            var result : Double? = nil
            
            switch(thisBinaryOp) {
            case "+":
                result = doBinaryOp(itemEarly, item2: itemLate, op: {$0 + $1})
                break
            case "-":
                result = doBinaryOp(itemEarly, item2: itemLate, op: {$0 - $1})
                break
            case "×":
                result = doBinaryOp(itemEarly, item2: itemLate, op: {$0 * $1})
                break
            case "÷":
                result = doBinaryOp(itemEarly, item2: itemLate, op: {$0 / $1})
                break
            default:
                break
            }
            displayValue = result!
            stack.append(result!)
            println(stack)
        }
    }
    
    func doBinaryOp(item1: Double, item2: Double, op: (Double, Double) -> Double) -> Double {
        return op(item1, item2)
    }
}