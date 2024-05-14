import Foundation
import Tea

open class Client {
    public static func getBoundary() -> String {
        "1" + String.randomString(len: 31, randomDict: "0123456789")
    }

    public static func toFileForm(_ map: [String: Any], _ boundary: String) -> TeaFileForm {
        let fileForm = TeaFileForm(map, boundary);
        return fileForm;
    }
}
