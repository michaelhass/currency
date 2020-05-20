//
//  InputForm.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import SwiftUI

// MARK: - InputFormObserver

protocol InputFormObserver {
    func editingStarted()
    func editingEnded(text: String)
    func editingCanceled()
    func textChanged(text: String)
}

// MARK: - InputForm

struct InputForm: View {

    // MARK: Bindings
    @State private var enteredText: String
    @State private var showCancel: Bool = false
    @State private var isEditing: Bool = false

    // MARK: Properties

    private let observer: InputFormObserver

    // MARK: Init

    init(observer: InputFormObserver, initialValue: String = "") {
        self.observer = observer
        self._enteredText = State(initialValue: initialValue)
        self._showCancel =  State(initialValue: false)
        self._isEditing =  State(initialValue: false)
    }

    // MARK: View Builder

    var body: some View {
        amountTextField()
    }

    func amountTextField() -> some View {

        let textBinding = Binding<String>.init(get: { () -> String in
            self.enteredText
        }, set: { text in
            self.enteredText = text
            self.observer.textChanged(text: text)
        })

        return HStack {
            TextField("Amount", text: textBinding, onEditingChanged: { editing in
                if editing {
                    self.observer.editingStarted()
                }
                self.showCancel = editing
                self.isEditing = editing

            }, onCommit: {
                self.observer.editingEnded(text: self.enteredText)
            })
                .keyboardType(.decimalPad)
                .foregroundColor(.primary)

            Button(action: {
                self.enteredText = ""
            }, label: {
                Image(systemName: "xmark.circle.fill")
            }).opacity(self.enteredText.isEmpty || !isEditing ? 0 : 1)

            if showCancel {
                Button("Cancel") {
                    self.showCancel = false
                    self.observer.editingCanceled()
                    UIApplication.shared.dismissKeyboard()
                }.foregroundColor(Color(.systemBlue))
            }
        }.padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
    }
}

struct InputForm_Previews: PreviewProvider {

    private struct Observer: InputFormObserver {
        func editingEnded(text: String) {}
        func editingStarted() {}
        func editingEnded() {}
        func editingCanceled() {}
        func textChanged(text: String) {}
    }

    static var previews: some View {
        InputForm(observer: Observer())
    }
}
