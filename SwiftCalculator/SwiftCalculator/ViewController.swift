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
    
    // Adds digit to display text, and checks if PI is pressed
    // Also checks to make sure floating point is legal
    @IBAction func pressedDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let pi = M_PI
        if numberExists {
            if digit == "π" {
                enter()
                display.text = "\(pi)"
                enter()
            } else if digit == "."{
                if display.text!.rangeOfString(".") == nil{
                    display.text = display.text! + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            if digit == "π" {
                display.text = "\(pi)"
                enter()
            } else {
                display.text = digit
                numberExists = true
            }
        }
        
    }
    
    
    @IBOutlet weak var historyLabel: UILabel!
    // Adds operand and operation to UI Label
    func addToHistory(value: String) {
        if historyLabel.text! == "0" {
            historyLabel.text = value
        } else {
            historyLabel.text = historyLabel.text! + " " + value
        }
    }
    
    // Performs operation and adds operation to history.
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if numberExists && operation != "C" {
            enter()
        }
        addToHistory("\(operation)")
        switch operation {
        case "*": performOperation { $0 * $1 }
        case "/": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "-": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "cos": performOperation { cos($0) }
        case "sin": performOperation { sin($0) }
        case "C": clearCalc()
        default: break
        }
    }
    
    // Clears calculator history and operand stack
    func clearCalc() {
        display.text = "0"
        while(!operandStack.isEmpty){
            operandStack.removeLast()
        }
        historyLabel.text = "0"
    }
    
    // Removes 2 numbers off stack and performs function
    func performOperation(operation:(Double,Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    // Removes number off stack and performs function
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    
    // Adds number to stack and history label
    @IBAction func enter() {
        numberExists = false
        operandStack.append(displayValue)
        addToHistory("\(displayValue)")
    }
    
    
    // Generates display value
    var displayValue: Double {
        get {
            let displayText = display.text!
            let textNumber = NSNumberFormatter().numberFromString(displayText)
            return textNumber!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            numberExists = false
        }
    }
}

