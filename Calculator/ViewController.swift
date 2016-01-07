//
//  ViewController.swift
//  Calculator
//
//  Created by Eugene Smitenko on 13.12.15.
//  Copyright © 2015 Eugene Smitenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayHistory: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                return NSNumberFormatter().numberFromString(displayText)?.doubleValue
            }
            return nil
        }
        set {
            userIsInTheMiddleOfTypingANumber = false
            displayHistory.text = brain.description
            guard let newNoNilValue = newValue else {
                display.text = "0"
                return
            }
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            numberFormatter.usesGroupingSeparator = false
            if let stringFromNewNoNilValue = numberFormatter.stringFromNumber(NSNumber(double: newNoNilValue)) {
                display.text = stringFromNewNoNilValue
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func appenDigit(sender: UIButton) {
        guard let digit = sender.currentTitle else {
            return
        }
        guard let displayText = display.text else {
            return
        }
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = displayText + digit
        } else {
            userIsInTheMiddleOfTypingANumber = true
            display.text = digit
        }
        print("Digit = \(digit)")
    }
    
    @IBAction func appendDot() {
        if let displayText = display.text {
            if displayText.rangeOfString(".") == nil {
                display.text?.append(Character("."))
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    @IBAction func enter() {
        if let currentDisplayValue = displayValue {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = brain.pushOperand(currentDisplayValue)
        }
    }
    
    @IBAction func clearAll() {
        brain.clearAll()
        displayValue = nil
    }

    @IBAction func backspace() {
        guard let displayText = display.text else {
            return
        }

        if displayText.characters.count > 1 {
            let index = displayText.endIndex.predecessor()
            display.text?.removeAtIndex(index)
        }
        else {
            displayValue = nil
            userIsInTheMiddleOfTypingANumber = false
        }
    }

    @IBAction func changeSign(sender: UIButton) {
        guard let displayText = display.text else {
            return
        }
        if userIsInTheMiddleOfTypingANumber {
            if displayText.rangeOfString("-") != nil {
                let index = displayText.startIndex
                display.text?.removeAtIndex(index)
            } else {
                display.text = "-" + displayText
            }
        } else {
            operate(sender)
        }
    }
    
   @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                if let displayHistoryText = displayHistory.text {
                    displayHistory.text = displayHistoryText + "="
                }
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if let variableName = sender.currentTitle {
            brain.pushOperand(variableName)
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        guard let valueOfVariable = displayValue else {
            return
        }
        guard let currentTitle = sender.currentTitle else {
            return
        }
        let variableName = String(currentTitle.characters.dropFirst())
        brain.variableValues[variableName] = valueOfVariable
        displayValue = brain.evaluate()
    }
}

