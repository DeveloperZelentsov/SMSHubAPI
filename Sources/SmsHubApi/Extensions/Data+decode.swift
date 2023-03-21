
import Foundation

extension Data {
    func decode<T: Decodable>(model: T.Type) -> T? {
        return try? JSONDecoder().decode(model, from: self)
    }
}
