//
//  ReviewMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//
import Foundation

extension Review {
    private static func getRandomImages() -> [String] {
        return Array(0...4).map { index in
            "https://picsum.photos/id/\(index)/200/300"
        }
    }
    
    static func mock(posterId: Int) -> Self {
        .init(creatorId: posterId,
              id: 1,
              name: "리뷰 테스트",
              date: Date().addingTimeInterval(-3600 * (24 * Double(Int.random(in: 6...100)))),
              participantsCount: Int.random(in: 1...10),
              address: "서울 강남구 선릉로100길 1 서울 강남구 선릉로100길 1 서울 강남구 선릉로100길 1",
              imagePaths: getRandomImages(),
              meet: .mock(id: 1),
              location: .mock())
    }
}

