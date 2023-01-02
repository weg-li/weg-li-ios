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
  public typealias S = ReportDomain.State
  public typealias A = ReportDomain.Action
  
  private let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
    
  public init(store: Store<S, A>) {
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
              action: A.images
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
              selection: viewStore.binding(\.$date)
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
              action: A.location
            )
          )
        }
        
        // Description
        Widget(
          title: Text(L10n.Description.widgetTitle),
          isCompleted: viewStore.isDescriptionValid
        ) {
          DescriptionView(store: store)
            .onTapGesture { viewStore.send(.set(\.$showEditDescription, true)) }
            .sheet(
              isPresented: viewStore.binding(\.$showEditDescription),
              content: {
                NavigationStack {
                  EditDescriptionView(
                    store: store.scope(
                      state: \.description,
                      action: A.description
                    )
                  )
                  .accessibilityAddTraits([.isModal])
                  .navigationTitle(Text(L10n.Description.widgetTitle))
                  .navigationBarTitleDisplayMode(.inline)
                  .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                      Button(
                        action: { viewStore.send(.set(\.$showEditDescription, false)) },
                        label: { Text(L10n.Button.close) }
                      )
                    }
                  }
                }
              }
            )
        }
        
        // Contact
        Widget(
          title: Text(L10n.Report.Contact.widgetTitle),
          isCompleted: viewStore.isContactValid
        ) {
          ContactWidget(store: store.scope(state: { $0 }))
            .onTapGesture { viewStore.send(.set(\.$showEditContact, true)) }
            .sheet(
              isPresented: viewStore.binding(\.$showEditContact),
              content: {
                NavigationStack {
                  ContactView(
                    store: store.scope(
                      state: \.contactState,
                      action: ReportDomain.Action.contact
                    )
                  )
                  .accessibilityAddTraits([.isModal])
                  .navigationBarItems(
                    leading: Button(
                      action: { viewStore.send(.set(\.$showEditContact, false)) },
                      label: { Text(L10n.Button.close) }
                    )
                  )
                }
              }
            )
        }
        
        // Send notice buttons
        VStack {
          if !viewStore.apiToken.isEmpty {
            VStack(spacing: .grid(1)) {
              Button(
                action: { viewStore.send(.onSubmitButtonTapped) },
                label: {
                  VStack(alignment: .center) {
                    if viewStore.isSubmittingNotice {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                      Label("Meldung senden", systemImage: "arrow.up.doc.fill")
                        .font(.body.bold())
                    }
                  }
                  .frame(maxWidth: .infinity, alignment: .center)
                }
              )
              .disabled(viewStore.canSubmitNotice || viewStore.isSubmittingNotice)
              .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: !viewStore.state.canSubmitNotice))
              .padding([.horizontal])
              .padding(.vertical, .grid(1))
              
              
            }
          } else {
            MailContentView(store: store)
              .padding()
          }
          
          VStack {
            if let district = viewStore.district {
              VStack {
                Text("Meldung wird gesendet an:")
                Text(district.email).bold()
              }
              .frame(maxWidth: .infinity)
              .font(.body)
              .padding()
              .overlay(
                RoundedRectangle(cornerRadius: 6)
                  .stroke(Color(uiColor: .lightGray), lineWidth: 1)
              )
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
                  if !viewStore.state.contactState.contact.isValid {
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
          .padding()
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
     ReportView(store:
        .init(
          initialState: .preview,
          reducer: ReportDomain()
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
