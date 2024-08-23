import UIKit

struct GroupInfo {
    let groudId: Int
    let name: String
    let creatorId: Int
    let creatorName: String
    let creatorDate: String
    let imageUrl: String
    let members : [GroupMember]
}

struct GroupMember {
    let memberId: Int
    let userId: Int
    let nickName: String
    let joinedDate: String
}

