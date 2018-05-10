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
    
    private var notificationTokens: [NotificationToken] = []
    
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
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        guard textField.isFirstResponder else { return }
        
        textField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Observations
    func registerKeyboardNotifications() {
        let center = NotificationCenter.default
        
        let keyboardWillShowToken = center.addObserver(with: UIViewController.keyboardWillShow) { (payload) in
            let contentInset = UIEdgeInsetsMake(0.0, 0.0, payload.endFrame.height, 0.0)
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
            
            var visibleFrame = self.scrollView.frame
            visibleFrame = CGRect(x: visibleFrame.minX, y: visibleFrame.minY, width: visibleFrame.width, height: visibleFrame.height - payload.endFrame.height)
            guard !visibleFrame.contains(self.textField.frame.origin) else { return }
            
            self.scrollView.scrollRectToVisible(self.textField.frame, animated: true)
        }
        notificationTokens.append(keyboardWillShowToken)
        
        let keyboardWillHideToken = center.addObserver(with: UIViewController.keyboardWillHide) { _ in
            let contentInset = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
        notificationTokens.append(keyboardWillHideToken)
    }
    
    func unregisterKeyboardNotifications() {
        notificationTokens.removeAll()
    }
}
