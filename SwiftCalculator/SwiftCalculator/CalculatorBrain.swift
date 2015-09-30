//
//  CalculatorBrain.swift
//  SwiftCalculator
//
//  Created by Sean Sabour on 9/14/15.
//  Copyright (c) 2015 Sean Sabour. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        case Variable(String)
        case Constant(String, Double)
        
        var isOperation: Bool {
            switch self {
            case .UnaryOperation, .BinaryOperation:
                return true
            default:
                return false
            }
        }
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    var variableValues = Dictionary<String, Double>()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("*", *))
        learnOp(Op.BinaryOperation("/") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.Constant("π", M_PI))
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // Guaranteed to be a property list
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func clear() -> Double? {
        opStack.removeAll()
        variableValues = Dictionary<String, Double>()
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            print("In evalute \(ops.count)")
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1  = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                if let operand = variableValues[symbol] {
                    return (operand, remainingOps)
                }
            case .Constant(_, let operand):
                return (operand, remainingOps)
            }
        }
        return (nil, ops);
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        let resultString = result?.description ?? "nil"
        print("\(opStack) = \(resultString) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    var description: String {
        get {
            var description: String? = nil
            var remainingOps = opStack
            while (!remainingOps.isEmpty) {
                let (result, remainder) = evaluateDescription(remainingOps)
                if (result != nil) {
                    description = description != nil ? "\(result!), \(description!)" : "\(result!)"
                }
                remainingOps = remainder
            }
            return description != nil ? description! : ""
        }
    }
    
    var lastOpIsAnOperation: Bool {
        get {
            return opStack.count > 0 && opStack[opStack.endIndex - 1].isOperation
        }
    }
    
    private func evaluateDescription(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var descriptionPart = ""
            var remainingOps = ops;
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                descriptionPart = "\(operand)"
            case .Variable(let symbol):
                descriptionPart = "\(symbol)"
            case .Constant(let symbol, _):
                descriptionPart = "\(symbol)"
            case .UnaryOperation(let symbol, _):
                let evaluated = remainingOps.isEmpty ? (result: "?", remainingOps: remainingOps) : evaluateDescription(remainingOps)
                remainingOps = evaluated.remainingOps
                descriptionPart = "\(symbol)(\(evaluated.result!))"
            case .BinaryOperation(let symbol, _):
                let evaluated1 = remainingOps.isEmpty ? (result: "?", remainingOps: remainingOps) : evaluateDescription(remainingOps)
                remainingOps = evaluated1.remainingOps
                let evaluated2 = remainingOps.isEmpty ? (result: "?", remainingOps: remainingOps) : evaluateDescription(remainingOps)
                remainingOps = evaluated2.remainingOps
                var evaluated1Result = evaluated1.result!
                if (symbol == "*" || symbol == "/") && (evaluated1Result.rangeOfString("+") != nil || evaluated1Result.rangeOfString("-") != nil) {
                    evaluated1Result = "(" + evaluated1Result + ")"
                }
                descriptionPart = "\(evaluated2.result!)\(symbol)\(evaluated1Result)"
            }
            return (descriptionPart, remainingOps)
        }
        return (nil, ops)
    }
}