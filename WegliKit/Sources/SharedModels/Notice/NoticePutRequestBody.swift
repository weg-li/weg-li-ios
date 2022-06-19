import Foundation

public struct NoticePutRequestBody: Codable, Equatable {
  public let notice: NoticeInput

  public init(notice: NoticeInput) {
    self.notice = notice
  }
}
