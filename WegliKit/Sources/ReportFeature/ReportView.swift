// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import DescriptionFeature
import Helper
import L10n
import ImagesFeature
import LocationFeature
import Styleguide
import SwiftUI

public struct ReportView: View {
  private let store: Store<ReportState, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ReportState, ReportAction>
    
  public init(store: Store<ReportState, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    ScrollView {
      VStack {
        Widget(
          title: Text("Datum"),
          isCompleted: true
        ) {
          VStack(alignment: .leading) {
            DatePicker(
              "Datum",
              selection: viewStore.binding(
                get: \.date,
                send: ReportAction.setDate
              )
            )
            .labelsHidden()
            .padding(.bottom)
            
            Text("Beim auswählen eines Fotos wird das Datum aus den Metadaten ausgelesen")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
        }
        // Photos
        Widget(
          title: Text(L10n.Photos.widgetTitle),
          isCompleted: viewStore.isPhotosValid
        ) {
          ImagesView(
            store: store.scope(
              state: \.images,
              action: ReportAction.images
            )
          )
        }
        
        // Location
        Widget(
          title: Text(L10n.Location.widgetTitle),
          isCompleted: viewStore.isLocationValid
        ) {
          LocationView(
            store: store.scope(
              state: \.location,
              action: ReportAction.location
            )
          )
        }
        
        // Description
        Widget(
          title: Text(L10n.Description.widgetTitle),
          isCompleted: viewStore.isDescriptionValid
        ) { DescriptionView(store: store) }
        
        // Contact
        Widget(
          title: Text(L10n.Report.Contact.widgetTitle),
          isCompleted: viewStore.isContactValid
        ) { ContactWidget(store: store.scope(state: { $0 })) }
        
        // Mail
        VStack {
          if viewStore.apiToken != nil {
            Button(
              action: { viewStore.send(.uploadImages) },
              label: {
                HStack {
                  if viewStore.isUploadingNotice {
                    ActivityIndicator(style: .medium, color: .white)
                      .foregroundColor(.white)
                  } else {
                    Text("Anzeige senden")
                  }
                }
                .frame(maxWidth: .infinity, alignment: .center)
              }
            )
            .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: !viewStore.state.isReportValid))
            .padding()
          } else {
            MailContentView(store: store)
              .padding()
          }
          
          if !viewStore.state.isReportValid {
            VStack(spacing: .grid(2)) {
              Text(L10n.Mail.readyToSubmitErrorCopy)
                .fontWeight(.semibold)
              VStack(spacing: .grid(1)) {
                if !viewStore.state.images.isValid {
                  Text(L10n.Report.Error.images.asBulletPoint)
                }
                if !viewStore.state.location.resolvedAddress.isValid {
                  Text(L10n.Report.Error.location.asBulletPoint)
                }
                if !viewStore.state.description.isValid {
                  Text(L10n.Report.Error.description.asBulletPoint)
                }
                if !viewStore.state.contactState.isValid {
                  Text(L10n.Report.Error.contact.asBulletPoint)
                }
              }
            }
            .accessibilityElement(children: .combine)
            .foregroundColor(.red)
            .font(.callout)
            .multilineTextAlignment(.center)
          }
        }
      }
    }
    .onAppear { viewStore.send(.onAppear) }
    .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        resetButton
      }
    }
    .navigationBarTitle(L10n.Report.navigationBarTitle, displayMode: .inline)
  }
  
  private var resetButton: some View {
    Button(
      action: { viewStore.send(.resetButtonTapped) },
      label: {
        Image(systemName: "arrow.counterclockwise")
          .foregroundColor(viewStore.isResetButtonDisabled ? .gray : .red)
      }
    )
    .accessibilityLabel(Text(L10n.Button.reset))
    .accessibilityValue(viewStore.isResetButtonDisabled ? "deaktiviert" : "aktiviert")
    .contentShape(Rectangle())
    .disabled(viewStore.isResetButtonDisabled)
  }
}

struct ReportForm_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      ReportView(
        store: .init(
          initialState: .preview,
          reducer: .empty,
          environment: ()
        )
      )
    }
  }
}

private extension String {
  var asBulletPoint: Self {
    "\u{2022} \(self)"
  }
}
