//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ziliang Zhu on 9/6/15.
//  Copyright (c) 2015 Austurela. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _):
                    return "\(symbol)"
                case .Variable(let variable):
                    return "\(variable)"
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var historyOpStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    var description: String {
        get {
            var copyStack: [Op] = historyOpStack
            var finalDescription = [String]()
            
            while !copyStack.isEmpty {
                finalDescription.insert(describe(&copyStack), atIndex: 0)
            }
            return ",".join(finalDescription) + "="
        }
    }
    
    init() {
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-", -)
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷", /)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        variableValues["π"] = M_PI
    }

    func getFunction() -> (Double -> Double)? {
        var copyOps: [Op] = opStack
        return getFunctions(&copyOps)
    }
    
    private func getFunctions(inout ops: [Op]) -> (Double -> Double)? {
        if !ops.isEmpty {
            let op = ops.removeLast()
            switch op {
            case .Operand(let operand):
                return {(m: Double) -> Double in return operand}
            case .Variable(let variable):
                return {(m: Double) -> Double in return m}
            case .UnaryOperation(_, let unaryFunction):
                if let resultFunc = getFunctions(&ops) {
                    return {(m: Double) -> Double in return unaryFunction(resultFunc(m))}
                } else {
                    break
                }
            case .BinaryOperation(_, let binaryFunction):
                if let lateResultFunc = getFunctions(&ops), earlyResultFunction = getFunctions(&ops) {
                    return {(m: Double) -> Double in return binaryFunction(earlyResultFunction(m), lateResultFunc(m))}
                } else {
                    break
                }
            }
        }
        return nil
    }
    
    func getFunctionDescription() -> String {
        var copyOps: [Op] = opStack
        return describe(&copyOps)
    }
    
    private func describe(inout ops: [Op]) -> String {
        if !ops.isEmpty {
            let op = ops.removeLast()
            switch op {
            case .Operand(let operand):
                return operand.description
            case .Variable(let variable):
                return variable
            case .UnaryOperation(let symbol, _):
                let result = describe(&ops)
                return "\(symbol)(\(result))"
            case .BinaryOperation(let symbol, _):
                let lateOperand = describe(&ops), earlyOperand = describe(&ops)
                return "(\(earlyOperand) \(symbol) \(lateOperand))"
            }
        }
        return "?"
    }
    
    private func evaluate(inout ops: [Op]) -> Double? {
        if !ops.isEmpty {
            let op = ops.removeLast()
            switch op {
            case .Operand(let operand):
                return operand
            case .UnaryOperation(_, let operation):
                if let operand = evaluate(&ops) {
                    return operation(operand)
                }
            case .BinaryOperation(_, let operation):
                if let operandLate = evaluate(&ops), operandEarly = evaluate(&ops) {
                    return operation(operandEarly, operandLate)
                }
            case .Variable(let symbol):
                return variableValues[symbol]
            default:
                println(op)
            }
        }
        return nil
    }
    
    func evaluate() -> Double? {
        println("evaluate \(opStack)")
        let backupStack: [Op] = opStack
        if let result = evaluate(&opStack) {
            return result
        } else {
            opStack = backupStack
            return nil
        }
    }
    
    func pushOperand(let operand: Double, let pushToHistory: Bool) {
        opStack.append(Op.Operand(operand))
        if pushToHistory {
            historyOpStack.append(Op.Operand(operand))
        }
    }
    
    func pushOperand(let symbol: String) {
        opStack.append(Op.Variable(symbol))
        historyOpStack.append(Op.Variable(symbol))
    }
    
    func performOperation(let symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            historyOpStack.append(operation)
        }
        return evaluate()
    }
    
    func reset() {
        opStack.removeAll()
        historyOpStack.removeAll()
        variableValues = ["π": M_PI]
    }
}