
import Foundation

final class Utils {
    /// The method creates a [URLQueryItem] object from the passed structure, signed under the Encodable protocol.
    /// - Parameter object: Object of the structure signed under the Encodable protocol.
    /// - Returns: [URLQueryItem] object.
    static func createURLQueryItems<T: Encodable>(from object: T) -> [URLQueryItem]? {
        do {
            let json = try JSONEncoder().encode(object)
            let dictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any]
            return dictionary?.map { URLQueryItem(name: $0, value: "\($1)") }
        } catch {
            return nil
        }
    }
}
