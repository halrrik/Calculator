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
            if let nsNumber = NSNumberFormatter().numberFromString(display.text!) {
                return nsNumber.doubleValue
            } else {
                display.text = "0"
                return nil
            }
        }
        set {
            if newValue == nil {
                display.text = "0"
            } else {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                numberFormatter.usesGroupingSeparator = false
                if let stringFromNewValue = numberFormatter.stringFromNumber(NSNumber(double: newValue!)) {
                    display.text = stringFromNewValue
                } else {
                    display.text = "0"
                }
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func appenDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            userIsInTheMiddleOfTypingANumber = true
            display.text = digit
        }
        print("Digit = \(digit)")
    }
    
    @IBAction func appendDot() {
        if display.text!.rangeOfString(".") == nil {
            display.text!.append(Character("."))
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    @IBAction func enter() {
        if displayValue != nil {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = brain.pushOperand(displayValue!)
            addToHistory(display.text!)
        }
    }
    
    @IBAction func clearAll() {
        displayValue = nil
        displayHistory.text!.removeAll()
        brain = CalculatorBrain()
    }

    @IBAction func backspace() {
        if display.text!.characters.count > 1 {
            let endIndex = display.text!.endIndex.predecessor()
            display.text!.removeAtIndex(endIndex)
        }
        else {
            displayValue = nil
            userIsInTheMiddleOfTypingANumber = false
        }
    }

    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.rangeOfString("-") != nil {
                let startIndex = display.text!.startIndex
                display.text!.removeAtIndex(startIndex)
            } else {
                display.text = "-" + display.text!
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
            displayValue = brain.performOperation(operation)
            addToHistory(operation)
            addToHistory("=")
        }
    }

    
    func addToHistory(text: String){
        if let indexRange = displayHistory.text!.rangeOfString("=") {
            print(displayHistory.text![indexRange.startIndex])
            displayHistory.text!.removeAtIndex(indexRange.startIndex)
        }
        displayHistory.text = displayHistory.text! + text + " "
    }

}

