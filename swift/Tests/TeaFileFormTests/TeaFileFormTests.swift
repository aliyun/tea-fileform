import Foundation
import XCTest
@testable import TeaFileForm

final class TeaFileFormTests: XCTestCase {

    func testFileFromStream() {
        let boundary: String = Client.getBoundary()
        let stream: TeaFileForm = Client.toFileForm([String: Any](), boundary)

        XCTAssertEqual(0, stream.bytes.count)
        stream.write(boundary.toBytes())
        XCTAssertEqual(32, stream.bytes.count)
    }

    func testRead() {
        let fileField = FileField()
        fileField.filename = "haveContent"
        fileField.contentType = "contentType"
        fileField.content = Data("This is file test. This sentence must be long".toBytes())

        let fileFieldNoContent = FileField()
        fileFieldNoContent.filename = "noContent"
        fileFieldNoContent.contentType = "contentType"
        fileFieldNoContent.content = nil

        let dict: [String: Any] = [
            "key": "value",
            "testKey": "testValue",
            "haveFile": fileField,
            "noFile": fileFieldNoContent
        ]

        let stream = Client.toFileForm(dict, "testBoundary")

        var readLength: Int = 0

        repeat {
            readLength = stream.read(0, 1024)
        } while readLength != 0

        let result: String = String(bytes: stream.bytes, encoding: .utf8) ?? ""
        let target: String = "--testBoundary\r\nContent-Disposition: form-data; name=\"haveFile\"; filename=haveContent\r\nContent-Type: contentType\r\n\r\nThis is file test. This sentence must be long\r\n--testBoundary\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue\r\n\r\n\r\n\r\n--testBoundary\r\nContent-Disposition: form-data; name=\"testKey\"\r\n\r\ntestValue\r\n\r\n\r\n--testBoundary--\r\n"
        XCTAssertEqual(target, result)
    }
}

class TestObject {
    var name: String = ""
    var value: Int = 0
}
