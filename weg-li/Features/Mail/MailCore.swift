// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI

struct MailViewState: Equatable {
    var mailComposeResult: MFMailComposeResult?
    var mail = Mail()
    var isPresentingMailContent = false
    var district: District = .init(name: "", zipCode: "", mail: "")
}

enum MailViewAction: Equatable {
    case submitButtonTapped
    case presentMailContentView(Bool)
    case setMailResult(MFMailComposeResult?)
}

struct MailViewEnvironment {}

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
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let mailComposeResult = try container.decodeIfPresent(Int.self)
        let mail = try container.decode(Mail.self)
        let district = try container.decode(District.self)
        self.init(
            mailComposeResult: MFMailComposeResult(rawValue: mailComposeResult ?? 0)!,
            mail: mail,
            isPresentingMailContent: false,
            district: district)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let result = mailComposeResult {
            try container.encode(result.rawValue)
        }
        try container.encode(mail)
    }
}
