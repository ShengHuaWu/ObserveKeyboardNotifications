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
        
        registerKeyboardNotifications()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
        
        textField.frame = CGRect(x: 20.0, y: scrollView.frame.height * 2.0 / 3.0, width: scrollView.frame.width - 40.0, height: 32.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterKeyboardNotifications()
    }
    
    // MARK: - Gesture Actions
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        guard textField.isFirstResponder else { return }
        
        textField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Observations
    func registerKeyboardNotifications() {
        let center = NotificationCenter.default
        
        let keyboardWillShowDescriptor = NotificationDescriptor(name: Notification.Name.UIKeyboardWillShow, convert: KeyboardPayload.init)
        center.addObserver(with: keyboardWillShowDescriptor) { (payload) in
            let contentInset = UIEdgeInsetsMake(0.0, 0.0, payload.endFrame.height, 0.0)
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
            
            var visibleFrame = self.scrollView.frame
            visibleFrame = CGRect(x: visibleFrame.minX, y: visibleFrame.minY, width: visibleFrame.width, height: visibleFrame.height - payload.endFrame.height)
            guard !visibleFrame.contains(self.textField.frame.origin) else { return }
            
            self.scrollView.scrollRectToVisible(self.textField.frame, animated: true)
        }
        
        let keyboardWillHideDescriptor = NotificationDescriptor(name: Notification.Name.UIKeyboardWillHide, convert: KeyboardPayload.init)
        center.addObserver(with: keyboardWillHideDescriptor) { _ in
            let contentInset = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    func unregisterKeyboardNotifications() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        center.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
}

