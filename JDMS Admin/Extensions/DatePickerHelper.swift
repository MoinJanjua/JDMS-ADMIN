//
//  DatePickerHelper.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 03/01/2026.
//

import UIKit

extension UIViewController {

    func attachDatePicker(
        to textField: UITextField,
        mode: UIDatePicker.Mode = .date,
        format: String = "dd-MM-yyyy",
        minimumDate: Date? = nil,
        maximumDate: Date? = nil
    ) {

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(handleDatePickerDone)
        )

        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        toolbar.setItems([space, doneBtn], animated: true)

        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar

        // Store picker & format using tag hack
        datePicker.tag = textField.hash
        textField.accessibilityHint = format
    }

    @objc private func handleDatePickerDone() {
        guard let textField = view.currentFirstResponder as? UITextField,
              let picker = textField.inputView as? UIDatePicker else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = textField.accessibilityHint ?? "dd-MM-yyyy"

        textField.text = formatter.string(from: picker.date)
        textField.resignFirstResponder()
    }
}

// MARK: - First Responder Finder
extension UIView {
    var currentFirstResponder: UIResponder? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.currentFirstResponder {
                return responder
            }
        }
        return nil
    }
}
