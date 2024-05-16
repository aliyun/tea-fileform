import Foundation
import Tea

public class FileField : Tea.TeaModel {
    public var filename: String?

    public var contentType: String?

    public var content: InputStream?

    public override init() {
        super.init()
    }

    public init(_ dict: [String: Any]) {
        super.init()
        self.fromMap(dict)
    }

    public override func validate() throws -> Void {
        try self.validateRequired(self.filename, "filename")
        try self.validateRequired(self.contentType, "contentType")
        try self.validateRequired(self.content, "content")
    }

    public override func toMap() -> [String : Any] {
        var map = super.toMap()
        if self.filename != nil {
            map["filename"] = self.filename!
        }
        if self.contentType != nil {
            map["contentType"] = self.contentType!
        }
        if self.content != nil {
            map["content"] = self.content!
        }
        return map
    }

    public override func fromMap(_ dict: [String: Any]) -> Void {
        if dict.keys.contains("filename") && dict["filename"] != nil {
            self.filename = dict["filename"] as! String
        }
        if dict.keys.contains("contentType") && dict["contentType"] != nil {
            self.contentType = dict["contentType"] as! String
        }
        if dict.keys.contains("content") && dict["content"] != nil {
            self.content = dict["content"] as! InputStream
        }
    }
}

class FileForm: InputStream {
    private var form: [String: Any]
    private var boundary: String
    private var keys: [String]
    private var keyIndex = 0
    private var fileNumber = 0
    private var files: [FileField] = []
    private var fileBodyStream: InputStream?
    private var temporaryStream: InputStream?
    private var temporaryEndStream: InputStream?
    private var endInputStream: InputStream?
    
    public init(_ form: [String: Any], _ boundary: String) {
        self.form = form
        self.boundary = boundary
        self.keys = Array(form.keys)
        self.keys = self.keys.sorted()
        super.init(data: Data())
        self.endInputStream = InputStream(data: "--\(boundary)--\r\n".data(using: .utf8)!)
        endInputStream?.open()
        prepareNextPart()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        fileBodyStream?.open()
        defer {
            fileBodyStream?.close()
        }
        var bytesRead = fileBodyStream?.read(buffer, maxLength: len) ?? 0
        if bytesRead > 0 { return bytesRead }
        
        temporaryStream?.open()
        defer {
            temporaryStream?.close()
        }
        bytesRead = temporaryStream?.read(buffer, maxLength: len) ?? 0
        if bytesRead > 0 { return bytesRead }
        
        temporaryEndStream?.open()
        defer {
            temporaryEndStream?.close()
        }
        bytesRead = temporaryEndStream?.read(buffer, maxLength: len) ?? 0
        if bytesRead > 0 { return bytesRead }
        
        if fileNumber > 0 || keyIndex < keys.count {
            prepareNextPart()
            return read(buffer, maxLength: len)
        }

        if endInputStream?.hasBytesAvailable == true {
            return endInputStream!.read(buffer, maxLength: len)
        }
        
        return -1
    }

    override var hasBytesAvailable: Bool {
        if keys.count <= 0 {
            return false
        }
        return fileBodyStream?.hasBytesAvailable ?? false ||
               temporaryStream?.hasBytesAvailable ?? false ||
               temporaryEndStream?.hasBytesAvailable ?? false ||
               endInputStream?.hasBytesAvailable ?? false ||
               keyIndex < keys.count || fileNumber > 0
    }
    
    override open func close() {
        fileBodyStream?.close()
        temporaryStream?.close()
        temporaryEndStream?.close()
        endInputStream?.close()
        
    }
    
    private func prepareNextPart() {
        guard keyIndex < keys.count else {
            if fileNumber > 0 {
                prepareFilePart()
            }
            return
        }
        
        let key = keys[keyIndex]
        let value = form[key]!
        
        if let fileField = value as? FileField {
            files.append(fileField)
            fileNumber += 1
            keyIndex += 1
            prepareFilePart()
        } else {
            let contentString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n"
            fileBodyStream?.close()
            fileBodyStream = InputStream(data: contentString.data(using: .utf8)!)
            keyIndex += 1
        }
    }
    
    private func prepareFilePart() {
        guard fileNumber > 0 else {
            return
        }
        
        let fileField = files.removeLast()
        fileNumber -= 1
        if fileField.content != nil {
            let fileHeaderString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(fileField.filename!)\"\r\nContent-Type: \(fileField.contentType!)\r\n\r\n"
            fileBodyStream?.close()
            fileBodyStream = InputStream(data: fileHeaderString.data(using: .utf8)!)
            temporaryStream?.close()
            temporaryStream = fileField.content
            temporaryEndStream?.close()
            temporaryEndStream = InputStream(data: "\r\n".data(using: .utf8)!)
        }
    }

}
