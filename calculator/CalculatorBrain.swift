//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Taco Ekkel on 1/29/15.
//  Copyright (c) 2015 Taco Ekkel. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case UnaryOperator(String, Double -> Double)
        case BinaryOperator(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch(self) {
                case .Operand(let operand): return "\(operand)"
                case .UnaryOperator(let symbol, _): return symbol
                case .BinaryOperator(let symbol, _): return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    
    init() {
        func addOp(op: Op) {
            knownOps[op.description] = op
        }
        addOp(Op.BinaryOperator("×", *))
        addOp(Op.BinaryOperator("÷") { $1 / $0 })
        addOp(Op.BinaryOperator("+", +))
        addOp(Op.BinaryOperator("−") { $1 - $0 })
        addOp(Op.UnaryOperator("√", sqrt))
        addOp(Op.BinaryOperator("^", pow))
        addOp(Op.UnaryOperator("sin", sin))
        addOp(Op.UnaryOperator("cos", cos))
    }
    
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
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
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperator(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperator(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) remaining")
        return result
    }
    
    private func clearStack() {
        opStack.removeAll(keepCapacity: false)
    }
    
    func reset() -> Double {
        clearStack()
        return 0
    }
}