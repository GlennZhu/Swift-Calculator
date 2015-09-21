//
//  ViewController.swift
//  Calculator
//
//  Created by Ziliang Zhu on 8/30/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var brain = CalculatorBrain()

    // This is the display area of the calculator
    @IBOutlet weak var display: UILabel!
    
    // This is the input history
    @IBOutlet weak var history: UILabel!
    
    // Those are flags to record the current state
    private var pressedEnter = false, pressedDot = false
    
    // This is used for dot button
    private var decimalBase: Double = 0.1
    
    /* This is used to flag if the calculater is started.
    This flag is used for special case for button Pi*/
    private var started: Bool = false, pushedOperation = false
    
    // The optional double expression of the displayed value
    private var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if newValue == nil {
                display.text = nil
            } else {
                display.text = "\(newValue!)"
            }
        }
    }
    
    @IBAction func pressC() {
        brain.reset()
        pressedEnter = false
        pressedDot = false
        decimalBase = 0.1
        started = false
        pushedOperation = false
        displayValue = 0
        history.text = " "
        history.text = brain.description
    }
    
    @IBAction func pressNumber(sender: UIButton) {
        started = true
        if let pressedNumber = NSNumberFormatter().numberFromString(sender.currentTitle!)?.doubleValue {
            if pressedEnter {
                displayValue = 0
                pressedEnter = false
            }
            if pressedDot {
                displayValue = displayValue! + decimalBase * pressedNumber
                decimalBase /= 10
            } else {
                displayValue = displayValue! * 10 + pressedNumber
            }
        }
    }
    
    @IBAction func pressEnter() {
        if !pressedEnter {
            pressEnter(true)
        }
        history.text = brain.description
    }
    
    private func pressEnter(pushToHistory: Bool) {
        if let result = displayValue {
            brain.pushOperand(result, pushToHistory: pushToHistory)
            readyForNewNumber()
        }
    }
    
    private func readyForNewNumber() {
        pressedEnter = true
        decimalBase = 0.1
        pressedDot = false
    }
    
    // This generically deals with +, -, *, and / operations
    @IBAction func pressOperation(sender: UIButton) {
        if started && !pressedEnter {
            pressEnter()
        }
        if let thisOp = sender.currentTitle, result = brain.performOperation(thisOp) where !result.isNaN {
            displayValue = result
            pressEnter(false)
            pushedOperation = true
        } else {
            displayValue = nil
        }
        history.text = brain.description
    }
    
    @IBAction func pressDot() {
        pressedDot = true
        started = true
    }

    // This execute Pi button as an operation
    @IBAction func pressPi() {
        if started && !pressedEnter {
            pressEnter(pushedOperation ? false : true)
        }
        brain.pushOperand("π")
        displayValue = M_PI
        history.text = brain.description
        readyForNewNumber()
    }
    
    // ->M
    @IBAction func pressSetM() {
        brain.variableValues["M"] = displayValue
        history.text = brain.description
        if let result = brain.evaluate() {
            displayValue = result
            brain.pushOperand(result, pushToHistory: false)

        }
        readyForNewNumber()
    }
    
    // M
    @IBAction func pressPushMVariable() {
        if started && !pressedEnter {
            pressEnter(pushedOperation ? false : true)
        }
        brain.pushOperand("M")
        history.text = brain.description
        if let result = brain.evaluate() {
            displayValue = result
            brain.pushOperand(result, pushToHistory: false)
        }
        readyForNewNumber()
    }
    
    // Graph
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = (segue.destinationViewController as? UINavigationController)?.visibleViewController
        if let graphViewController = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch(identifier) {
                case "graph" :
                    graphViewController.setFunctionToDraw(brain.getFunction())
                    graphViewController.showFunction(brain.getFunctionDescription())
                default:
                    break
                }
            }
        }
    }
}