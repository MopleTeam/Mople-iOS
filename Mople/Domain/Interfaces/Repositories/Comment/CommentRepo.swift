//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

protocol CommentRepo {

    // MARK: - CRUD
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) async throws -> CommentResponse
    func fetchCommentList(postId: Int,
                          nextCursor: String?) async throws -> PageResponse<CommentResponse>
    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) async throws -> CommentResponse
    func deleteComment(commentId: Int) async throws

    // MARK: - Reply
    func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) async throws -> CommentResponse
    func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) async throws -> PageResponse<CommentResponse>

    // MARK: - Like
    func likeComment(commentId:Int) async throws -> CommentResponse
}
