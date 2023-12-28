// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct ContactWidget: View {
  let contact: Contact
  let buttonAction: () -> Void

  public init(contact: Contact, buttonAction: @escaping () -> Void) {
    self.contact = contact
    self.buttonAction = buttonAction
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: .grid(2)) {
      VStack(alignment: .leading, spacing: .grid(2)) {
        row(callout: L10n.Contact.Row.nameCopy, content: contact.fullName)
        row(callout: L10n.Contact.Row.streetCopy, content: contact.address.street)
        row(callout: L10n.Contact.Row.cityCopy, content: contact.address.city)
        if !contact.phone.isEmpty {
          row(callout: L10n.Contact.Row.phoneCopy, content: contact.phone)
        }
        if !contact.dateOfBirth.isEmpty {
          row(callout: L10n.Contact.Row.dateOfBirth, content: contact.dateOfBirth)
        }
        if !contact.address.addition.isEmpty {
          row(callout: L10n.Contact.Row.addressAddition, content: contact.address.addition)
        }
      }
      .accessibilityElement(children: .combine)
      VStack(spacing: .grid(2)) {
        Button(
          action: buttonAction,
          label: {
            Label(L10n.Contact.editButtonCopy, systemImage: "square.and.pencil")
              .frame(maxWidth: .infinity)
          }
        )
        .accessibilitySortPriority(3)
        .buttonStyle(.edit())
        .padding(.top)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
    .contentShape(Rectangle())
  }
  
  private func row(callout: String, content: String) -> some View {
    HStack {
      Text(callout)
        .foregroundColor(Color(.secondaryLabel))
        .font(.callout)
      if !content.isEmpty {
        Spacer()
        Text(content)
          .foregroundColor(Color(.label))
          .font(.body)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  ContactWidget(contact: .preview, buttonAction: {})
}
