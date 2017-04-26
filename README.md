## Observe iOS Keyboard Notifications
User input request is a common feature of an iOS application, especially, during sign-up or log-in process.
When users touch a text field, a text view, or a field in a web view, the system displays a keyboard. However,
sometimes the keyboard will be placed on the top of an app's content, the app should adjust the content that is located under the keyboard and keep it visible.
In order to achieve this, the app can observe the corresponding notifications when the keyboard is shown or hidden.

### Handle Keyboard Notifications with Selectors
Let's say there is a text field on the bottom of a scroll view.
When the keyboard is shown, we should move the scroll view up and keep the text field visible.
On the other hand, we should move everything back to the original location when the keyboard is hidden.
According to [Apple's documentation](https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html), we can use `NotificationCenter`'s `addObserver` method and listen to `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` in our view controller.
```
let center = NotificationCenter.default
center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
```
Then, when the keyboard is shown, we obtain the necessary value from the notification's `userInfo` and change `contentInset` of the scroll view within our `keyboardWillBeShown` method.
Finally, we invoke `UIScrollView`'s `scrollRectToVisible` method to actually reveal the text field.
```
func keyboardWillBeShown(note: Notification) {
    let userInfo = note.userInfo
    let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
    let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.height, 0.0)
    scrollView.contentInset = contentInset
    scrollView.scrollIndicatorInsets = contentInset
    scrollView.scrollRectToVisible(textField.frame, animated: true)
}
```
When the keyboard is hidden, we just assign `contentInset` to `UIEdgeInsets.zero` and move the scroll view back to the original position.
```
func keyboardWillBeHidden(note: Notification) {
    let contentInset = UIEdgeInsets.zero
    scrollView.contentInset = contentInset
    scrollView.scrollIndicatorInsets = contentInset
}
```
This is a very typical solution to handle keyboard's notifications.

### A More Swifty Way
So, what's the problem?
The first problem is there are actually [many other values](https://developer.apple.com/reference/uikit/uiwindow/keyboard_notification_user_info_keys) inside notification's `userInfo`, such as the animation curve and the animation duration, and they are necessary for several situations.
Secondly, we don't want to spread optional chaining and force casting over our codebase because they are error prone.
However, it's possible to improve our solution with a swifty way.
First of all, let's introduce a generic struct called `NotifictaionDescriptor`.
It stores the notification name and a closure used to convert the notification into a generic payload.
```
struct NotificationDescriptor<Payload> {
    let name: Notification.Name
    let convert: (Notification) -> Payload
}
```
Moreover, I write an extension of `NotificationCenter` to add an observer with my `NotificationDescriptor`.
Please notice that I pass `nil` into object and queue parameters just for simplicity.
```
extension NotificationCenter {
    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> ()) {
        addObserver(forName: descriptor.name, object: nil, queue: nil) { (note) in
            block(descriptor.convert(note))
        }
    }
}
```
After that, I create another struct called `KeyboardPayload` to store the values inside notification's `userInfo` and handle the parsing in its `init` method.
```
struct KeyboardPayload {
    let beginFrame: CGRect
    let endFrame: CGRect
    let curve: UIViewAnimationCurve
    let duration: TimeInterval
    let isLocal: Bool
}

extension KeyboardPayload {
    init(note: Notification) {
        let userInfo = note.userInfo
        beginFrame = userInfo?[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        curve = UIViewAnimationCurve(rawValue: userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        isLocal = userInfo?[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
}
```
For convenience, I also write an extension of `UIViewController` and generate the corresponding descriptors under this namespace.
```
extension UIViewController {
    static let keyboardWillShow = NotificationDescriptor(name: Notification.Name.UIKeyboardWillShow, convert: KeyboardPayload.init)
    static let keyboardWillHide = NotificationDescriptor(name: Notification.Name.UIKeyboardWillHide, convert: KeyboardPayload.init)
}
```
Finally, I can leverage the `NotificationDescriptor` and `NotificationCenter`'s new `addObserver` method within my view controller to adjust the scroll view and the text field.
```
let center = NotificationCenter.default

center.addObserver(with: UIViewController.keyboardWillShow) { (payload) in
    let contentInset = UIEdgeInsetsMake(0.0, 0.0, payload.endFrame.height, 0.0)
    self.scrollView.contentInset = contentInset
    self.scrollView.scrollIndicatorInsets = contentInset
    self.scrollView.scrollRectToVisible(self.textField.frame, animated: true)
}

center.addObserver(with: UIViewController.keyboardWillHide) { _ in
    let contentInset = UIEdgeInsets.zero
    self.scrollView.contentInset = contentInset
    self.scrollView.scrollIndicatorInsets = contentInset
}
```
However, there is still one thing needs to be noticed. Because I invoke the `addObserver(forName:, object:, queue:, using:)` method, it's necessary to remove the observer when the view controller is deallocated. Otherwise, the app will crash.

### Conclusion
The sample project is [here](https://github.com/ShengHuaWu/ObserveKeyboardNotifications).

This approach is inspired by [objc.io Swift Talk](https://talk.objc.io/episodes/S01E27-typed-notifications-part-1). If you haven't watch it, I highly recommend that you should visit the website and watch the episode.
Although it looks like more lines of code to write, there are several benefits when adopting this approach.
The first one is that we can reuse the descriptor for other [iOS system notifications](https://developer.apple.com/reference/foundation/nsnotification.name) and create other payload structs to parse the values we want.
Furthermore, it's also possible to utilize this mechanism to custom notification with notification's `object` property instead of `userInfo`.
I believe this is a more appropriate solution to handle iOS notifications in Swift.
Any comment and feedback are welcome, so please share your thoughts. Thank you!
