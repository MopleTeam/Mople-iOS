//
//  ImageUploadPath.swift
//  Domain
//
//  이미지 업로드 경로 — 서버 폴더 구분용 enum

import Foundation

/// 이미지 업로드 대상 폴더
public enum ImageUploadPath: String {
    case profile = "profile"
    case meet = "meet"
    case review = "review"
}
