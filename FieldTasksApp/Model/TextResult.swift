import Foundation

@objc(TextResult)
open class TextResult: _TextResult {
    override func save(newText : String) {
       completed_private = false
        text = newText
        if text!.count > 0 {
           completed_private = true
        }
    }

    override func fromDict(results: [String : AnyObject]) {
        super.fromDict(results: results)
        text = results["text"] as? String ?? ""
    }

    override func toDict() -> [String : AnyObject]{
        var dict = super.toDict()
        dict["text"] = (text ?? "") as AnyObject?
        return dict
    }

    override func resultString() -> String {
        return text ?? ""
    }
}
