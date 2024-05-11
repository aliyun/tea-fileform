import Foundation
import Tea

public class Client {
    public static func getBoundary() -> String {
        "1" + String.randomString(len: 31, randomDict: "0123456789")
    }

    public static func toFileForm(_ map: [String: Any], _ boundary: String) -> TeaFileForm {
        let fileForm = TeaFileForm(map, boundary);
        return fileForm;
    }
}

public class TeaFileForm {
    private var form: [String: Any]
    private var keys: [String]
    private var boundary: String
    private var streaming: Bool
    private var stream: Data?

    public var bytes: [UInt8] = [UInt8]()
    public var index: Int

    private var readPos: Int = 0

    public init(_ map: [String: Any], _ boundary: String) {
        self.form = map
        self.keys = Array(map.keys)
        self.keys = self.keys.sorted()
        self.index = 0
        self.boundary = boundary
        self.streaming = false
    }

    public func read(_ off: Int, _ count: Int) -> Int {
        if self.streaming {
            if self.stream != nil && self.stream?.count != 0 {
                let dataLen: Int = self.stream?.count ?? 0
                let offset: Int = self.readPos + off
                if offset >= dataLen {
                    return self.next(endStr: "\r\n")
                }
                let range = dataLen < offset + count ? offset..<(dataLen - offset) : offset..<count
                let data: Data = self.stream!
                var readContentBytes: [UInt8] = [UInt8](repeating: 0, count: data.count)
                data.copyBytes(to: &readContentBytes, from: range)
                self.bytes = self.bytes + readContentBytes
                self.readPos = self.readPos + readContentBytes.count
                return readContentBytes.count
            } else {
                return self.next(endStr: "\r\n")
            }
        }
        if self.index > self.keys.count {
            return 0
        }
        if self.keys.count > 0 {
            if self.index < self.keys.count {
                self.streaming = true
                let name: String = self.keys[self.index]
                let fieldValue = self.form[name]
                let tmp: [String]
                let field: FileField? = fieldValue as? FileField
                if field != nil {
                    if field?.filename != nil && field?.contentType != nil && field?.content != nil {
                        tmp = [
                            "--", self.boundary, "\r\n",
                            "Content-Disposition: form-data; name=\"", name, "\"; filename=", field!.filename!, "\r\n",
                            "Content-Type: ", (field?.contentType ?? ""), "\r\n\r\n"
                        ]
                        let body: [UInt8] = tmp.joined().toBytes()
                        self.bytes = self.bytes + body
                        self.stream = field?.content!
                        return body.count
                    } else {
                        return self.next(endStr: "\r\n")
                    }
                } else {
                    let val: String = String(describing: fieldValue ?? "").percentEncode()
                    tmp = [
                        "--", self.boundary, "\r\n",
                        "Content-Disposition: form-data; name=\"", name, "\"\r\n\r\n",
                        val, "\r\n\r\n"
                    ]
                    let body: [UInt8] = tmp.joined().toBytes()
                    self.bytes = self.bytes + body
                    return body.count
                }
            } else if (self.index == self.keys.count) {
                return self.next(endStr: "--" + boundary + "--\r\n")
            } else {
                return 0
            }
        }
        return 0
    }

    private func next(endStr: String) -> Int {
        self.streaming = false
        self.bytes = self.bytes + endStr.toBytes()
        self.index = self.index + 1
        self.stream = nil
        self.readPos = 0
        return endStr.count
    }

    public func write(_ bytes: [UInt8]) {
        self.bytes = self.bytes + bytes
    }

    public func ReadAsync(_ offset: Int, _ count: Int, _ callback: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "TeaFileFormQueue", attributes: .init(rawValue: 0))
        queue.async {
            let index: Int = self.read(offset, count)
            callback(index)
        }
    }

    public func getData() -> Data {
        Data(self.bytes)
    }
}

public class FileField: TeaModel {
    public var filename: String?
    public var contentType: String?
    public var content: Data?

    public override init() {
        super.init()
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
