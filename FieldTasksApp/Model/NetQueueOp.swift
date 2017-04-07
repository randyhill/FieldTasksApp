import Foundation

@objc(NetQueueOp)
open class NetQueueOp: _NetQueueOp {
	// Custom logic goes here.
    func compare(other : NetQueueOp) -> Bool {
        if other.typeName == self.typeName && other.objectKey == self.objectKey {
            return true
        }
        return false
    }

    func describe() -> String {
        return "type: \(self.typeName!) key: \(self.objectKey!)"
    }
}
