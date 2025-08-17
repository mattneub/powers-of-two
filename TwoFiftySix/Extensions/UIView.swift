import UIKit

extension UIView {
    /// Get a list of subviews of a given type, recursing or not. By default, only non-hidden views
    /// are returned.
    ///
    /// - Parameters:
    ///   - ofType: The desired type; for example, `UIButton.self`.
    ///   - recursing: Whether to recurse through all subviews. The default is `true`.
    ///   - includeHidden: If `true`, all subviews are eligible to be returned. If `false`, only
    ///     non-hidden subviews will be returned.
    /// - Returns: An array whose elements are of type `WhatType`, which may be empty.
    ///
    func subviews<T: UIView>(
        ofType whatType: T.Type,
        recursing: Bool = true,
        includeHidden: Bool = false
    ) -> [T] {
        let views = subviews.filter { !$0.isHidden || includeHidden }
        var result: [T] = views.compactMap { $0 as? T }
        guard recursing else { return result }
        for view in views {
            result.append(contentsOf: view.subviews(ofType: whatType, includeHidden: includeHidden))
        }
        return result
    }

    /// Async version of `animateWithDuration`. There is no completion handler; if there is something to do
    /// after the animation ends, just do it after awaiting the call.
    /// - Parameters:
    ///   - duration: Duration of the animation.
    ///   - delay: Delay before beginning the animation, or 0 to begin immediately.
    ///   - options: Mask of animation options.
    ///   - animations: Function containing animatable changes to commit to the views.
    ///
    @objc class func animateAsync(withDuration duration: Double, delay: Double, options: UIView.AnimationOptions, animations: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            Self.animate(withDuration: duration, delay: delay, options: options, animations: animations) { _ in
                continuation.resume(returning: ())
            }
        }
    }

    /// Async version of `transitionWithView`. There is no completion handler; if there is something to do
    /// after the animation ends, just do it after awaiting the call.
    /// - Parameters:
    ///   - view: The view to be animated.
    ///   - duration: Duration of the animation.
    ///   - options: Animation options describing the transition.
    ///
    @objc class func transitionAsync(with view: UIView, duration: Double, options: UIView.AnimationOptions) async {
        await withCheckedContinuation { continuation in
            Self.transition(with: view, duration: duration, options: options, animations: {}) { _ in
                continuation.resume(returning: ())
            }
        }
    }
}
