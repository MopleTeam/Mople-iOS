//
//  MemberListType.swift
//  Domain
//
//  멤버 목록 조회 대상 구분

import Foundation

/// 멤버 목록을 어떤 기준으로 조회할지 구분하는 타입
public enum MemberListType {
    case meet(id: Int?)
    case plan(id: Int?)
    case review(id: Int?)
}
