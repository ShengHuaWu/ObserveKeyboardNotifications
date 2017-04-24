//
//  ViewController.swift
//  ObserveKeyboardNotifications
//
//  Created by ShengHua Wu on 24/04/2017.
//  Copyright © 2017 ShengHua Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "This is a text field."
        return textField
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(textField)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        textField.frame = CGRect(x: 20.0, y: scrollView.frame.height * 2.0 / 3.0, width: scrollView.frame.width - 40.0, height: 32.0)
    }
    
    // MARK: - Gesture Actions
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        guard textField.isFirstResponder else { return }
        
        textField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Notification Selectors
    func keyboardWillBeShown(note: Notification) {
        debugPrint("keyboard will show")
    }
    
    func keyboardWillBeHidden(note: Notification) {
        debugPrint("keyboard will hide")
    }
}

