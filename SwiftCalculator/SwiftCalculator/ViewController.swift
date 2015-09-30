//
//  ViewController.swift
//  Calculator
//
//  Created by Sean Sabour on 8/27/15.
//  Copyright (c) 2015 Sean Sabour. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var numberExists = false
    var brain = CalculatorBrain()
    
    // Adds digit to display text, and checks if PI is pressed
    // Also checks to make sure floating point is legal
    @IBAction func pressedDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if numberExists {
            if digit == "."{
                if display.text!.rangeOfString(".") == nil{
                    display.text = display.text! + digit
                }
            }else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            numberExists = true
        }
        updateHistory()
    }
    
    // Adds operand and operation to UI Label
    @IBOutlet weak var history: UILabel!
    
    func updateHistory() {
        history.text = brain.description + (!numberExists && brain.lastOpIsAnOperation ? "=" : "")
    }
    
    // Performs operation and adds operation to history.
    @IBAction func operate(sender: UIButton) {
        if numberExists {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        updateHistory()
    }
    
    // Clears calculator history and operand stack
    @IBAction func clearCalc(sender: UIButton?) {
        display.text = "0"
        brain.clear()
        numberExists = false
        updateHistory()
    }
    
    
    // Adds number to stack and history label
    @IBAction func enter() {
        numberExists = false
        if let result = brain.pushOperand(displayValue ?? 0) {
            displayValue = result;
        } else {
            displayValue = nil
        }
        updateHistory()
    }
    
    @IBAction func pushM(sender: UIButton) {
        if numberExists {
            enter()
        }
        if let result = brain.evaluate(){
            brain.pushOperand("M")
            displayValue = result
        } else {
            displayValue = nil
        }
        updateHistory()
    }
    
    @IBAction func setM(sender: UIButton) {
        if displayValue != nil {
            numberExists = false
            brain.variableValues["M"] = displayValue
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        updateHistory()
    }
    
    // Generates display value
    var displayValue: Double? {
        get {
            if let displayValueAsDouble = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return displayValueAsDouble
            }
            return nil
        } set {
            display.text = newValue != nil ? "\(newValue!)" : " "
            numberExists = false
        }
    }
    
    override func viewDidLoad() {
        clearCalc(nil)
    }
}

