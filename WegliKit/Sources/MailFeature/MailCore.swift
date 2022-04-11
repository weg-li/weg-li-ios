// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
import SharedModels

public struct MailViewState: Equatable {
  public init(
    mailComposeResult: MFMailComposeResult? = nil,
    mail: Mail = Mail(),
    isPresentingMailContent: Bool = false
  ) {
    self.mailComposeResult = mailComposeResult
    self.mail = mail
    self.isPresentingMailContent = isPresentingMailContent
  }
  
  public var mailComposeResult: MFMailComposeResult?
  public var mail = Mail()
  public var isPresentingMailContent = false
}

public enum MailViewAction: Equatable {
  case submitButtonTapped
  case presentMailContentView(Bool)
  case setMailResult(MFMailComposeResult?)

  case copyMailToAddress
  case copyMailBody
}

public struct MailViewEnvironment {
  public init() {}
}

/// Reducer handling Mail submit actions and result.
public let mailViewReducer = Reducer<MailViewState, MailViewAction, MailViewEnvironment> { state, action, _ in
  switch action {
  case .submitButtonTapped:
    return .none
  case let .presentMailContentView(value):
    state.isPresentingMailContent = value
    return .none
  case let .setMailResult(value):
    state.mailComposeResult = value
    return .none
    
  case .copyMailBody:
    UIPasteboard.general.string = state.mail.body
    return .none
  
  case .copyMailToAddress:
    UIPasteboard.general.string = state.mail.address
    return .none
  }
}

extension MailViewState: Codable {
  private enum CodingKeys: String, CodingKey {
    case mailComposeResult
    case mail
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let mailComposeResult = try container.decodeIfPresent(Int.self, forKey: .mailComposeResult)
    let mail = try container.decode(Mail.self, forKey: .mail)
    self.init(
      mailComposeResult: MFMailComposeResult(rawValue: mailComposeResult ?? 0)!, // swiftlint:disable:this force_unwrapping
      mail: mail,
      isPresentingMailContent: false
    )
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch mailComposeResult {
    case .none:
      try container.encodeNil(forKey: .mailComposeResult)
    case let .some(value):
      try container.encode(value.rawValue, forKey: .mailComposeResult)
    }
    try container.encode(mail, forKey: .mail)
  }
}
