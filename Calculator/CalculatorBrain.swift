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
        case Operand(Double)
        case UnaryOperation(String, (Double) -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        
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
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−"){$1 - $0})
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷"){$1 / $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("log", log))
        learnOp(Op.UnaryOperation("±"){-$0})
        learnOp(Op.Constant("π", M_PI))
        learnOp(Op.Constant("e", M_E))
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
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
            case .Operand(let operand):
                return (operand, remaningOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remaningOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaningOps)
                }
            case .BinaryOperation(_, let operation):
                let firstOperandEvaluation = evaluate(remaningOps)
                if let firstOperand = firstOperandEvaluation.result {
                    let secondOperandEvaluation = evaluate(firstOperandEvaluation.remaningOps)
                    if let secondOperand = secondOperandEvaluation.result {
                        return(operation(firstOperand, secondOperand), secondOperandEvaluation.remaningOps)
                    }
                }
            case .Constant(_, let constant):
                return (constant, remaningOps)
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