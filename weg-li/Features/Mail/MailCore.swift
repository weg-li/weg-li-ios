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
    private enum CodingKeys: String, CodingKey {
        case mailComposeResult
        case mail
        case district
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mailComposeResult = try container.decodeIfPresent(Int.self, forKey: .mailComposeResult)
        let mail = try container.decode(Mail.self, forKey: .mail)
        let district = try container.decode(District.self, forKey: .district)
        self.init(
            mailComposeResult: MFMailComposeResult(rawValue: mailComposeResult ?? 0)!,
            mail: mail,
            isPresentingMailContent: false,
            district: district)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch mailComposeResult {
        case .none:
            try container.encodeNil(forKey: .mailComposeResult)
        case .some(let value):
            try container.encode(value.rawValue, forKey: .mailComposeResult)
        }
        try container.encode(mail, forKey: .mail)
        try container.encode(district, forKey: .district)
    }
}
