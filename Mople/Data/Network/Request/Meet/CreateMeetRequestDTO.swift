//
//  CreateMeetRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import Domain

// MARK: - 모임 생성/수정 API 요청 DTO
struct CreateMeetRequestDTO: Encodable {
    var name: String?
    var image: String?
}

// MARK: - Domain → DTO 변환
extension CreateMeetRequestDTO {
    init(request: CreateMeetRequest) {
        self.name = request.name
        self.image = request.image
    }
}
