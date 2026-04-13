//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

public protocol CommentRepo {

    // MARK: - CRUD
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) async throws -> Comment
    func fetchCommentList(postId: Int,
                          nextCursor: String?) async throws -> Page<Comment>
    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) async throws -> Comment
    func deleteComment(commentId: Int) async throws

    // MARK: - Reply
    func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) async throws -> Comment
    func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) async throws -> Page<Comment>

    // MARK: - Like
    func likeComment(commentId: Int) async throws -> Comment
}
