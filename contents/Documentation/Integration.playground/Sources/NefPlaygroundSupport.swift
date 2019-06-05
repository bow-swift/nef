import UIKit

public protocol NefPlaygroundLiveViewable {}
extension UIView: NefPlaygroundLiveViewable {}
extension UIViewController: NefPlaygroundLiveViewable {}

#if NOT_IN_PLAYGROUND
public enum Nef {
    public enum Playground {
        public static func liveView(_ view: NefPlaygroundLiveViewable) {}
        public static func needsIndefiniteExecution(_ state: Bool) {}
    }
}

#else
import PlaygroundSupport

public enum Nef {
    public enum Playground {
        public static func liveView(_ view: NefPlaygroundLiveViewable) {
            PlaygroundPage.current.liveView = (view as! PlaygroundLiveViewable)
        }
        
        public static func needsIndefiniteExecution(_ state: Bool) {
            PlaygroundPage.current.needsIndefiniteExecution = state
        }
    }
}

#endif
