import Foundation
import Tea

open class Client {
    public static func getBoundary() -> String {
        "1" + String.randomString(len: 31, randomDict: "0123456789")
    }

    public static func toFileForm(_ map: [String: Any], _ boundary: String) -> InputStream {
        let fileForm = FileForm(map, boundary);
        return fileForm;
    }
}

extension String {
    static func randomString(len: Int, randomDict: String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int.random(in: 0..<randomDict.count)
            ranStr.append(randomDict[randomDict.index(randomDict.startIndex, offsetBy: index)])
        }
        return ranStr
    }

    func toBytes() -> [UInt8] {
        [UInt8](self.utf8)
    }

    func percentEncode() -> String {
        let unreserved = "*-._"
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: unreserved)
        allowedCharacterSet.addCharacters(in: " ")
        var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
        encoded = encoded?.replacingOccurrences(of: " ", with: "%20")
        return encoded ?? ""
    }
}
