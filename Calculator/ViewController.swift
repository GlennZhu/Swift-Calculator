//
//  ViewController.swift
//  Calculator
//
//  Created by Ziliang Zhu on 8/30/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // This is the display area of the calculator
    @IBOutlet weak var display: UILabel!
    
    // This is the input history
    @IBOutlet weak var history: UILabel!
    
    // This records what is entered into the calculator
    private var stack = Array<Double>()
    
    // Those are flags to record the current state
    private var pressedEnter = false, pressedDot = false
    
    // This is used for dot button
    private var decimalBase: Double = 0.1
    
    /* This is used to flag if the calculater is started.
    This flag is used for special case for button Pi*/
    private var started: Bool = false
    
    // The double expression of the displayed value
    private var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        set {
            display.text = "\(newValue)"
        }
    }
    
    // Add the all the button press event to the history label
    @IBAction func addHistory(sender: UIButton) {
        let pressed = sender.currentTitle!
        history.text = history.text! + pressed
    }
    
    @IBAction func pressC() {
        // Recover all the states
        stack.removeAll()
        pressedEnter = false
        pressedDot = false
        decimalBase = 0.1
        started = false
        displayValue = 0
        history.text = ""
        println(stack)
    }
    
    @IBAction func pressNumber(sender: UIButton) {
        started = true
        let pressedNumber = (sender.currentTitle! as NSString).doubleValue
    
        if pressedEnter {
            // Recover the states
            displayValue = 0
            pressedEnter = false

        }
        if pressedDot {
            // Add number on the decimal part
            displayValue += decimalBase * pressedNumber
            decimalBase /= 10
        } else {
            // Add number on the integer part
            displayValue = displayValue * 10 + pressedNumber
        }
    }
    
    @IBAction func pressEnter() {
        // Set relevant states
        stack.append(displayValue)
        pressedEnter = true
        decimalBase = 0.1
        pressedDot = false
        println(stack)
    }
    
    // This generically deals with +, -, *, and / operations
    @IBAction func pressBinaryOp(sender: UIButton) {
        if started && !pressedEnter {
            pressEnter()
        }
        if stack.count >= 2 {
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
        }
        println(stack)
    }
    
    // This generically deals with sin and cos operations
    @IBAction func pressUnaryOp(sender: UIButton) {
        if started && !pressedEnter {
            pressEnter()
        }
        if stack.count >= 1 {
            let thisUnaryOp = sender.currentTitle!
            let topItem = stack.removeLast()
            var result: Double? = nil
            
            switch (thisUnaryOp) {
                case "sin":
                    result = doUnaryOp(topItem, op: {sin($0)})
                    break
                case "cos":
                    result = doUnaryOp(topItem, op: {cos($0)})
                    break
                default:
                    break;
            }
            displayValue = result!
            stack.append(result!)
            pressedEnter = true
        }
        println(stack)
    }
    
    @IBAction func pressDot() {
        pressedDot = true
        started = true
    }
    
    // This execute Pi button as an operation
    @IBAction func pressPi() {
        if started && !pressedEnter {
            pressEnter()
        }
        stack.append(M_PI)
        displayValue = M_PI
        pressedEnter = true
        println(stack)
    }
    
    private func doBinaryOp(item1: Double, item2: Double,
        op: (Double, Double) -> Double) -> Double {
        return op(item1, item2)
    }
    
    private func doUnaryOp(item: Double, op: Double -> Double) -> Double {
        return op(item)
    }
}