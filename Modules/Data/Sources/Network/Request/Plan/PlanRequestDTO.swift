//
//  PlanRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import Domain

// MARK: - 일정 요청 타입 DTO — 생성(meetId) 또는 수정(planId) 구분
public enum PlanRequestTypeDTO {
    case create(meetId: Int)
    case edit(planId: Int)
}

// MARK: - 일정 생성/수정 API 요청 DTO
public struct PlanRequestDTO: Encodable {
    public let type: PlanRequestTypeDTO
    public let name: String
    public let date: String
    public var description: String?
    public var place: UploadPlace?

    enum CodingKeys: String, CodingKey {
        case name, title, planAddress, lat, lot, weatherAddress, planId, meetId, description
        case date = "planTime"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(place?.title, forKey: .title)
        try container.encodeIfPresent(place?.planAddress, forKey: .planAddress)
        try container.encodeIfPresent(place?.lat, forKey: .lat)
        try container.encodeIfPresent(place?.lot, forKey: .lot)
        try container.encodeIfPresent(place?.weatherAddress, forKey: .weatherAddress)
        try container.encodeIfPresent(description, forKey: .description)

        switch type {
        case let .create(meetId):
            try container.encode(meetId, forKey: .meetId)
        case let .edit(planId):
            try container.encode(planId, forKey: .planId)
        }
    }
}

// MARK: - Domain → DTO 변환
public extension PlanRequestDTO {
    init(request: PlanRequest) {
        switch request.type {
        case .create(let meetId):
            self.type = .create(meetId: meetId)
        case .edit(let planId):
            self.type = .edit(planId: planId)
        }
        self.name = request.name
        self.date = request.date
        self.description = request.description
        if let placeInfo = request.place {
            self.place = UploadPlace(place: placeInfo)
        }
    }
}
