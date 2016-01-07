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
        case Variable(String)
        
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
    private var knownOps = [String : Op]()
    
    var variableValues = [String : Double]()
    var description: String {
        return fullDescription(opStack)
    }
    
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

    func clearVariables() {
        variableValues.removeAll()
    }
    
    func clearStack() {
        opStack.removeAll()
    }
    
    func clearAll() {
        clearVariables()
        clearStack()
    }
    private func description(ops: [Op]) -> (result: String?, remaningOps: [Op]){
        if !ops.isEmpty {
            var remaningOps = ops
            let op = remaningOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remaningOps)
            case .UnaryOperation(let operation, _):
                let operandDescription = description(remaningOps)
                let operand = operandDescription.result ?? "?"
                return ("\(operation)(\(operand))", operandDescription.remaningOps)

            case .BinaryOperation(let operation, _):
                let firstOperandDescription = description(remaningOps)
                var firstOperand = firstOperandDescription.result ?? "?"
                if remaningOps.count - firstOperandDescription.remaningOps.count > 2 {
                    firstOperand = "(\(firstOperand))"
                }
                let secondOperandDescription = description(firstOperandDescription.remaningOps)
                let secondOperand = secondOperandDescription.result ?? "?"
                return("\(secondOperand)\(operation)\(firstOperand)", secondOperandDescription.remaningOps)
            case .Constant(let constantName, _):
                return (constantName, remaningOps)
            case .Variable(let variableName):
                return (variableName, remaningOps)
            }
        }
        return (nil, ops)
    }
    
    private func fullDescription(ops: [Op]) -> String {
        let remaningOps = ops
        var resultDescription = ""
        let ddd = description(remaningOps)
        resultDescription = ddd.result ?? ""
        if ddd.remaningOps.count > 0 {
            resultDescription = "\(fullDescription(ddd.remaningOps)), \(resultDescription)"
        }
        return resultDescription
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
            case .Variable(let variable):
                return (variableValues[variable], remaningOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        print(description)
        return result
    }
}