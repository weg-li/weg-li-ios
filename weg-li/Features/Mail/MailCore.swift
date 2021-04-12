// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI

struct MailViewState: Equatable {
    var mailComposeResult: MFMailComposeResult?
    var mail = Mail()
    var isPresentingMailContent = false
}

enum MailViewAction: Equatable {
    case submitButtonTapped
    case presentMailContentView(Bool)
    case setMailResult(MFMailComposeResult?)
}

struct MailViewEnvironment {}

/// Reducer handling Mail submit actions and result.
let mailViewReducer = Reducer<MailViewState, MailViewAction, MailViewEnvironment> { state, action, _ in
    switch action {
    case .submitButtonTapped:
        return .none
    case let .presentMailContentView(value):
        state.isPresentingMailContent = value
        return .none
    case let .setMailResult(value):
        state.mailComposeResult = value
        return .none
    }
}

extension MailViewState: Codable {
    private enum CodingKeys: String, CodingKey {
        case mailComposeResult
        case mail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mailComposeResult = try container.decodeIfPresent(Int.self, forKey: .mailComposeResult)
        let mail = try container.decode(Mail.self, forKey: .mail)
        self.init(
            mailComposeResult: MFMailComposeResult(rawValue: mailComposeResult ?? 0)!,
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
