// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
import SharedModels

public struct MailDomain: ReducerProtocol {
  public init() {}
  
  
  public struct State: Equatable {
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
  
  public enum Action: Equatable {
    case submitButtonTapped
    case presentMailContentView(Bool)
    case setMailResult(MFMailComposeResult?)

    case copyMailToAddress
    case copyMailBody
  }
  
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
}
