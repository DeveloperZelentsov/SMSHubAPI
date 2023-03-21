
import Foundation

extension Int {
    var localStatusCode: String {
        return HTTPURLResponse.localizedString(forStatusCode: self)
    }
}
