//
//  DateRangePickerViewController.swift
//  RiverPrime
//
//  Created by abrar ul haq on 04/06/2025.
//

import UIKit

class DateRangePickerViewController: BaseViewController {

    let fromLabel = UILabel()
    let toLabel = UILabel()
    let fromDatePicker = UIDatePicker()
    let toDatePicker = UIDatePicker()
    let cancelButton = UIButton(type: .system)
    let applyButton = UIButton(type: .system)
    
    var onApply: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupPopupUI()
        
        // Add target to dismiss date picker when a date is selected
        fromDatePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        toDatePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
    }
    
    @objc private func dateSelected() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }

    private func setupBackground() {
        // Dimmed background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setupPopupUI1() {
        let popupView = UIView()
        popupView.backgroundColor = UIColor.systemGray6
        popupView.layer.cornerRadius = 16
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowOffset = CGSize(width: 0, height: 5)
        popupView.layer.shadowRadius = 10
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 320),
            popupView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Labels
        fromLabel.text = "From:"
        fromLabel.textColor = .black
        fromLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toLabel.text = "To:"
        toLabel.textColor = .black
        toLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Add border and corner radius to labels for better styling
        fromLabel.layer.borderWidth = 1
        fromLabel.layer.borderColor = UIColor.gray.cgColor
        fromLabel.layer.cornerRadius = 8
        toLabel.layer.borderWidth = 1
        toLabel.layer.borderColor = UIColor.gray.cgColor
        toLabel.layer.cornerRadius = 8
        
        // DatePickers
        fromDatePicker.datePickerMode = .date
        fromDatePicker.preferredDatePickerStyle = .compact
        fromDatePicker.maximumDate = Date()
        fromDatePicker.layer.cornerRadius = 8
        fromDatePicker.layer.borderWidth = 1
        fromDatePicker.layer.borderColor = UIColor.gray.cgColor
        
        toDatePicker.datePickerMode = .date
        toDatePicker.preferredDatePickerStyle = .compact
        toDatePicker.maximumDate = Date()
        toDatePicker.layer.cornerRadius = 8
        toDatePicker.layer.borderWidth = 1
        toDatePicker.layer.borderColor = UIColor.gray.cgColor
        
        // Buttons
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.setTitleColor(.systemBlue, for: .normal)
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        applyButton.layer.cornerRadius = 8
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        
        // StackView for buttons
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        // StackView for all components (labels, date pickers, and buttons)
        let stack = UIStackView(arrangedSubviews: [
            fromLabel, fromDatePicker,
            toLabel, toDatePicker,
            buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 16 // Increased spacing for better separation
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        popupView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20)
        ])
    }

    private func setupPopupUI() {
        let popupView = UIView()
        popupView.backgroundColor = UIColor.systemGray6
        popupView.layer.cornerRadius = 16
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 320),
            popupView.heightAnchor.constraint(equalToConstant: 300)
        ])

        // Labels
        fromLabel.text = "From:"
        fromLabel.textColor = .black
        toLabel.text = "To:"
        toLabel.textColor = .black

        // DatePickers
        fromDatePicker.datePickerMode = .date //.dateAndTime
        fromDatePicker.preferredDatePickerStyle = .compact
        fromDatePicker.maximumDate = Date()
        toDatePicker.datePickerMode = .date //.dateAndTime
        toDatePicker.preferredDatePickerStyle = .compact
        toDatePicker.maximumDate = Date()

        // Buttons
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.lightGray, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.lightGray.cgColor
        applyButton.setTitle("Apply", for: .normal)
        applyButton.setTitleColor(.systemBlue, for: .normal)
        applyButton.layer.cornerRadius = 8
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = UIColor.systemBlue.cgColor

        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [
            fromLabel, fromDatePicker,
            toLabel, toDatePicker,
            buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        popupView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func applyTapped() {
        // Get the start and end date
        let startDate = fromDatePicker.date
        let endDate = toDatePicker.date
        
        // Remove the time portion by normalizing the dates to the start of the day
        let calendar = Calendar.current
        let normalizedStartDate = calendar.startOfDay(for: startDate)
        let normalizedEndDate = calendar.startOfDay(for: endDate)
        
        print("startDate = \(normalizedStartDate)")
        print("endDate = \(normalizedEndDate)")
        
        // Validate the date range
        if normalizedEndDate < normalizedStartDate {
            // Show the error message if end date is earlier than start date
            showTimeAlert(str: "End date cannot be earlier than start date.")
            return // Prevent further action
        }
        
        // Calculate the difference in months
        let monthsDifference = Calendar.current.dateComponents([.month], from: normalizedStartDate, to: normalizedEndDate).month ?? 0
        if monthsDifference > 2 {
            print("ERROR: The difference between From and To dates cannot exceed 2 months.")
            self.showTimeAlert(str: "The difference between From and To dates cannot exceed 2 months.")
            // Optionally, show an alert to the user
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy" //"dd-MM-yyyy" //"MMM dd, yyyy" //"MMM dd, yyyy HH:mm"
        print("From:", formatter.string(from: fromDatePicker.date))
        print("To:", formatter.string(from: toDatePicker.date))
        
        onApply?(formatter.string(from: fromDatePicker.date), formatter.string(from: toDatePicker.date))
//        onApply?(fromDatePicker.date, toDatePicker.date)
        dismissSelf()
    }
    
}
