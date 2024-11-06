//
//  PlanResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

protocol PlanProtocol: Decodable {
    var id: Int? { get }
    var title: String? { get }
    var releaseDate: String? { get }
    var participants: [UserInfoResponseDTO]? { get }
}

#warning("서버와 대조필요")
struct PlanResponseDTO: PlanProtocol {
    var id: Int?
    var title: String?
    var releaseDate: String?
    var participants: [UserInfoResponseDTO]?
    
    var groupId: Int?
    var groupTitle: String?
    var groupThumbnailPath: String?
    
    var address: String?
    var detailAddress: String?
    var longitude: Double?
    var latitude: Double?
    var temperature: Int?
    var weatherIconPath: String?
    var comments: [CommentResponseDTO]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case releaseDate = "startAt"
        case participants
        case groupId
        case groupTitle
        case groupThumbnailPath
        case address
        case detailAddress
        case longitude
        case latitude
        case temperature
        case weatherIconPath = "weatherIconUrl"
        case comments = "activeComments"
    }
}

extension PlanResponseDTO {
    func toDomain() -> Plan {
        return .init(id: id,
                     title: title,
                     releaseDate: releaseDate,
                     group: getGroup(),
                     participants: getUsers(),
                     location: getLocation(),
                     weather: getWeather())
    }
    
    private func getWeather() -> WeatherInfo {
        return WeatherInfo(address: address,
                           imagePath: weatherIconPath,
                           temperature: temperature)
    }
    
    private func getLocation() -> LocationInfo {
        return LocationInfo(detailAddress: detailAddress,
                            longitude: longitude,
                            latitude: latitude)
    }
    
    private func getGroup() -> Group { 
        return Group(id: groupId,
                     title: groupTitle,
                     thumbnailPath: groupThumbnailPath)
    }
    
    private func getUsers() -> [UserInfo] {
        guard let participants else { return [] }
        
        return participants.map { $0.toDomain() }
    }
    
    private func getComments() -> [Comment] {
        guard let comments else { return [] }
        
        return comments.map { $0.toDomain() }
    }
}

struct CommonPlanDTO: Decodable {
    let id: Int?
    let title: String?
    let date: String?
    let participants: [UserInfoResponseDTO]?
    let address: String?
    let detailAddress: String?
    let temperature: Int?
    let weatherIconPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case date = "startAt"
        case participants
        case address
        case detailAddress
        case temperature
        case weatherIconPath = "weatherIconUrl"
    }
}

struct SimplePlanDTO: Decodable {
    
    let common: CommonPlanDTO?
    let groupTitle: String?
    let groupThumbnailPath: String?
    
    enum CodingKeys: String, CodingKey {
        case groupTitle, groupThumbnailPath
    }
    
    init(from decoder: Decoder) throws {
        common = try CommonPlanDTO(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.groupTitle = try container.decodeIfPresent(String.self, forKey: .groupTitle)
        self.groupThumbnailPath = try container.decodeIfPresent(String.self, forKey: .groupThumbnailPath)
    }
}

struct DetailPlanDTO: Decodable {
    
    let common: CommonPlanDTO?
    var longitude: Double?
    var latitude: Double?
    var comments: [CommentResponseDTO]?
    
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        case comments = "activeComments"
    }
    
    init(from decoder: Decoder) throws {
        common = try CommonPlanDTO(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.comments = try container.decodeIfPresent([CommentResponseDTO].self, forKey: .comments)
    }
}
