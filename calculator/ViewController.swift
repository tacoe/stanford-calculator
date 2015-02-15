//
//  ViewController.swift
//  calculator
//
//  Created by Taco Ekkel on 1/27/15.
//  Copyright (c) 2015 Taco Ekkel. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingNumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        func interpret(num: String) -> String {
            if(num == "π") {
                return "3.14159328"
            } else {
                return num
            }
        }
        
        let digit = interpret(sender.currentTitle!)
        
        if userIsInTheMiddleOfTypingNumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingNumber = true
        }

    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = -1
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = -1;
        }
        
    }
    
    @IBAction func clear() {
        displayValue = brain.reset()
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingNumber = false
        }
    }
    
}

