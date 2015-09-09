import Foundation

var friendMgr: FriendManager = FriendManager()



class Friend {
    
    var name: String
    var amount: Double
    var multiplier: Int
    var pay: Double?
    var detail: [Transaction]?
    init(name:String, amount: Double, multiplier: Int){
        self.name = name
        self.amount = amount
        self.multiplier = multiplier
        self.pay = 0.0
        self.detail = []
    }
    func cleanDetail() {
        self.detail = []
    }
}

struct Transaction {
    let oweName: String
    let paidName: String
    let amount: Double
}

class FriendManager: NSObject {
    var friends = [Friend]()
    var paid = [Friend]()
    var owed = [Friend]()
    var summary = [Transaction]()
    
    
    // MARK: - public action functions
    func addFriend(name: String, amount: Double, multiplier: Int) {
        
        var temp:Double = NSString(format: "%.02f", amount).doubleValue
        friends.append(Friend(name: name, amount: temp, multiplier: multiplier))
    }
    
    func evalute() {
        summary.removeAll()
        for friend in friends {
            friend.cleanDetail()
        }
        splitTwoNSetPay()
        findExactMatch()
        while !paid.isEmpty && !owed.isEmpty {
            compare();
        }
    }
    
    // MARK: - public calculate functions
    func total() -> Double {
        var total: Double = 0
        for friend in friends {
            total += friend.amount
        }
        return total
    }
    
    func average() -> Double {
        if !friends.isEmpty {
            return NSString(format: "%.02f", total()/Double(getTotalPeople())).doubleValue
        }
        else {
            return 0.0
        }
    }
    
    func different() -> Double {
        return NSString(format: "%.02f", Double(average()*Double(getTotalPeople())).distanceTo(total())).doubleValue
    }
    
    
    func getTotalPeople() -> Int {
        var totalPeople: Int = 0
        for friend in friends {
            totalPeople += friend.multiplier
        }
        return totalPeople
    }
    
    // MARK: - private actions functions
    private func splitTwoNSetPay() {
        for friend in friends {
            //split into two array and start calculator
            let multAverage = average() * Double(friend.multiplier)
            if friend.amount > multAverage {
                friend.pay = NSString(format: "%.02f", friend.amount - multAverage).doubleValue
                paid.append(friend)
            }
            else if friend.amount < multAverage {
                friend.pay = NSString(format: "%.02f", multAverage - friend.amount).doubleValue
                owed.append(friend)
            }
        }
        remainAmount()
        sortTwoArrays()
    }
    
    private func findExactMatch() {
        if !paid.isEmpty && !owed.isEmpty {
            for var i = paid.endIndex-1; i >= 0; i-- {
                if let index: Int = binarySearch(paid[i].pay!, data: owed) {
                    if index >= 0 {
                        addSummaryAndDetail(owed[index].name, paidName: paid[i].name, amount: paid[i].pay!)
                        owed.removeAtIndex(index)
                        paid.removeAtIndex(i)
                    }
                    
                }
            }
            sortTwoArrays()
        }
    }
    
    private func compare() {
        var largestPaid: Double = -1
        var largestOwed: Double = -1
        if !paid.isEmpty {
            largestPaid = paid[0].pay!
        }
        if !owed.isEmpty {
            largestOwed = owed[0].pay!
        }
        if largestOwed > 0 && largestPaid > 0 {
            if largestPaid > largestOwed {
                addSummaryAndDetail(owed[0].name, paidName: paid[0].name, amount: owed[0].pay!)
                owed.removeAtIndex(0)
                let remaining: Double = NSString(format: "%.02f", largestPaid - largestOwed).doubleValue
                if let remainingIndex: Int = binarySearch(remaining, data: owed) {
                    if remainingIndex >= 0 {
                        addSummaryAndDetail(owed[remainingIndex].name, paidName: paid[0].name, amount: remaining)
                        paid.removeAtIndex(0)
                        owed.removeAtIndex(remainingIndex)
                    }
                    else {
                        paid[0].pay = remaining
                    }
                }
            }
            else {
                addSummaryAndDetail(owed[0].name, paidName: paid[0].name, amount: paid[0].pay!)
                paid.removeAtIndex(0)
                let remaining: Double = NSString(format: "%.02f", largestOwed - largestPaid).doubleValue
                if let remainingIndex: Int = binarySearch(remaining, data: paid) {
                    if remainingIndex >= 0 {
                        addSummaryAndDetail(owed[0].name, paidName: paid[remainingIndex].name, amount: remaining)
                        owed.removeAtIndex(0)
                        paid.removeAtIndex(remainingIndex)
                    }
                    else {
                        owed[0].pay = remaining
                    }
                }
            }
            
        }
        
        sortTwoArrays()
    }
    
    // MARK: - private utilties
    private func binarySearch(key: Double, data: [Friend]) -> Int? {
        var low: Int = 0
        var high: Int = data.count-1
        while high >= low {
            var middle: Int = (low + high) / 2
            if data[middle].pay == key {
                return middle
            }
            else if data[middle].pay > key {
                low = middle+1
            }
            else {
                high = middle-1
            }
            
        }
        return -1
    }
    
    private func addDetail(target: String, oweName: String, paidName: String, amount: Double) {
        if let found = find( lazy(friends).map({$0.name}), target) {
            let obj = friends[found]
            obj.detail!.append(Transaction(oweName: oweName, paidName: paidName, amount: amount))
        }
        
    }
    
    private func addSummaryAndDetail(oweName: String, paidName: String, amount: Double) {
        summary.append(Transaction(oweName: oweName, paidName: paidName, amount: amount))
        addDetail(oweName, oweName: oweName, paidName: paidName, amount: amount)
        addDetail(paidName, oweName: oweName, paidName: paidName, amount: amount)
        
    }
    
    private func sortTwoArrays() {
        paid.sort { (friend1: Friend, friend2: Friend) -> Bool in
            return friend1.pay > friend2.pay
        }
        owed.sort { (friend1: Friend, friend2: Friend) -> Bool in
            return friend1.pay > friend2.pay
        }
    }
    
    private func remainAmount() {
        let dif: Double = different()
        if !paid.isEmpty {
            paid[0].pay = paid[0].pay! - dif
        }
    }
}
