// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import DescriptionFeature
import Helper
import ImagesFeature
import L10n
import LocationFeature
import Styleguide
import SwiftUI

public struct ReportView: View {
  private let store: Store<ReportState, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ReportState, ReportAction>
    
  public init(store: Store<ReportState, ReportAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    ScrollView {
      VStack {
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

        // Date
        Widget(
          title: Text(L10n.date),
          isCompleted: true
        ) {
          VStack(alignment: .leading) {
            DatePicker(
              L10n.date,
              selection: viewStore.binding(
                get: \.date,
                send: ReportAction.setDate
              )
            )
            .labelsHidden()
            .padding(.bottom)

            Text(L10n.Report.Notice.Photos.dateHint)
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
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
        
        // Send notice buttons
        VStack {
          if !viewStore.apiToken.isEmpty {
            VStack(spacing: .grid(1)) {
              Button(
                action: { viewStore.send(.onUploadImagesButtonTapped) },
                label: {
                  VStack(alignment: .center) {
                    HStack {
                      if viewStore.isUploadingNotice {
                        ProgressView()
                          .progressViewStyle(CircularProgressViewStyle(tint: .white))
                      } else {
                        Label("Meldung hochladen", systemImage: "arrow.up.doc.fill")
                      }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                  }
                }
              )
              .disabled(viewStore.isUploadingNotice)
              .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: !viewStore.state.isReportValid))
              .padding([.horizontal])
              .padding(.vertical, .grid(1))
              
              Button(
                action: { viewStore.send(.submitNotice) },
                label: {
                  VStack(alignment: .center) {
                    if viewStore.isSubmittingNotice {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                      Label("Anzeige erstatten", systemImage: "paperplane.fill")
                    }
                  }
                  .frame(maxWidth: .infinity, alignment: .center)
                }
              )
              .disabled(viewStore.canSubmitNotice)
              .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: !viewStore.state.canSubmitNotice))
              .padding([.horizontal])
              .padding(.vertical, .grid(1))
            }
          } else {
            MailContentView(store: store)
              .padding()
          }
          
          VStack {
            VStack {
              Text("1. Lade zuerst deine Meldung hoch").bold()
              Text("2. Erstatte die Anzeige").bold()
            }
            .padding()
            .overlay(
              RoundedRectangle(cornerRadius: 6)
                .stroke(Color(uiColor: .lightGray), lineWidth: 1)
            )
            
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
              .padding(.bottom)
            }
          }
          }
      }
      .disabled(viewStore.isUploadingNotice)
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
      action: { viewStore.send(.onResetButtonTapped) },
      label: {
        Image(systemName: "arrow.counterclockwise")
          .foregroundColor(viewStore.isResetButtonDisabled ? .gray : .red)
      }
    )
    .accessibilityLabel(Text(L10n.Button.reset))
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
