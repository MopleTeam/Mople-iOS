//
//  CreateMeetRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import Domain

// MARK: - 모임 생성/수정 API 요청 DTO
public struct CreateMeetRequestDTO: Encodable {
    public var name: String?
    public var image: String?
}

// MARK: - Domain → DTO 변환
public extension CreateMeetRequestDTO {
    init(request: CreateMeetRequest) {
        self.name = request.name
        self.image = request.image
    }
}
