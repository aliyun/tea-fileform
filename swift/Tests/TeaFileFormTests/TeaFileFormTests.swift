import Foundation
import Tea
import XCTest
@testable import TeaFileForm

final class TeaFileFormTests: XCTestCase {

    func testFileFromStream() {
        let boundary: String = Client.getBoundary()
        XCTAssertEqual(32, boundary.toBytes().count)
        let stream: InputStream = Client.toFileForm([String: Any](), boundary)
        XCTAssertFalse(stream.hasBytesAvailable)
    }

    func testFileFieldFromMapThroughTeaModel() throws {
        let file = FileField()
        let model: TeaModel = file
        let content = InputStream(data: Data([0x00, 0xff, 0x0d, 0x0a]))

        model.fromMap(nil)
        XCTAssertNil(file.filename)
        model.fromMap([
            "filename": "payload.bin",
            "contentType": "application/octet-stream",
            "content": content
        ])
        try file.validate()
        XCTAssertEqual(file.filename, "payload.bin")
        XCTAssertEqual(file.contentType, "application/octet-stream")
        XCTAssertTrue(file.content === content)

        model.fromMap(["filename": nil, "contentType": "application/custom"])
        XCTAssertEqual(file.filename, "payload.bin")
        XCTAssertEqual(file.contentType, "application/custom")
        XCTAssertTrue(file.content === content)
    }

    func testRead() {
        let fileField = FileField()
        fileField.filename = "filename"
        fileField.contentType = "text/plain; charset=utf-8"
        fileField.content = InputStream(data: Data("This is file test. This sentence must be long".toBytes()))

        let fileFieldNoContent = FileField()
        fileFieldNoContent.filename = "no-content"
        fileFieldNoContent.contentType = "text/plain; charset=utf-8"
        fileFieldNoContent.content = nil

        let dict: [String: Any] = [
            "key": "value",
            "testKey": "testValue",
            "file": fileField,
            "noFile": fileFieldNoContent
        ]

        let fileFormStream = Client.toFileForm(dict, "boundary")

        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var totalData = Data()
        while fileFormStream.hasBytesAvailable {
            let bytesRead = fileFormStream.read(&buffer, maxLength: bufferSize)
            if bytesRead <= 0 {
                break
            }
            totalData.append(buffer, count: bytesRead)
        }

        let result: String = String(data: totalData, encoding: .utf8) ?? ""
        let target: String = "--boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"filename\"\r\nContent-Type: text/plain; charset=utf-8\r\n\r\nThis is file test. This sentence must be long\r\n--boundary\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue\r\n--boundary\r\nContent-Disposition: form-data; name=\"testKey\"\r\n\r\ntestValue\r\n--boundary--\r\n"
        XCTAssertEqual(target, result)
    }
}
