import Foundation

@objc(NetOpsQueue)
open class NetOpsQueue: _NetOpsQueue {
	// Custom logic goes here.
    func describe() -> String {
        var description = "Coredata Net Ops: \(relationship.count)"
        let ops =  opsDataArray()
        for op in ops {
            description += ", " + op.describe()
        }
        return description + "\n"
    }

    func opsDataArray() -> [NetQueueOp] {
        return self.relationshipSet().array as! [NetQueueOp]
    }
}
