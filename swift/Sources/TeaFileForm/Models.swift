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
