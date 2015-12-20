//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Eugene Smitenko on 17.12.15.
//  Copyright © 2015 Eugene Smitenko. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case operand(Double)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String : Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.binaryOperation("+", +))
        learnOp(Op.binaryOperation("−"){$1 - $0})
        learnOp(Op.binaryOperation("×", *))
        learnOp(Op.binaryOperation("÷"){$1 / $0})
        learnOp(Op.unaryOperation("√", sqrt))
        learnOp(Op.unaryOperation("cos", cos))
        learnOp(Op.unaryOperation("sin", sin))
        learnOp(Op.unaryOperation("log", log))
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remaningOps: [Op]){
        if !ops.isEmpty {
            var remaningOps = ops
            let op = remaningOps.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, remaningOps)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(remaningOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaningOps)
                }
            case .binaryOperation(_, let operation):
                let firstOperandEvaluation = evaluate(remaningOps)
                if let firstOperand = firstOperandEvaluation.result {
                    let secondOperandEvaluation = evaluate(firstOperandEvaluation.remaningOps)
                    if let secondOperand = secondOperandEvaluation.result {
                        return(operation(firstOperand, secondOperand), secondOperandEvaluation.remaningOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
}