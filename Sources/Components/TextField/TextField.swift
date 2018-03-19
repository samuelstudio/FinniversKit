//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

// MARK: - TextFieldDelegate

public protocol TextFieldDelegate: NSObjectProtocol {
    func textFieldDidBeginEditing(_ textField: TextField)
    func textFieldDidEndEditing(_ textField: TextField)
    func textFieldShouldReturn(_ textField: TextField) -> Bool
    func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldDidChange(_ textField: TextField)
    func textFieldDidTapMultilineAction(_ textField: TextField)
}

public extension TextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldDidEndEditing(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldShouldReturn(_ textField: TextField) -> Bool {
        return true
    }

    func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidChange(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldDidTapMultilineAction(_ textField: TextField) {
        // Default empty implementation
    }
}

public class TextField: UIView {
    enum UnderlineHeight: CGFloat {
        case inactive = 1
        case active = 2
    }

    // MARK: - Internal properties

    private let eyeImage = UIImage(frameworkImageNamed: "view")!.withRenderingMode(.alwaysTemplate)
    private let clearTextIcon = UIImage(frameworkImageNamed: "remove")!.withRenderingMode(.alwaysTemplate)
    private let multilineDisclosureIcon = UIImage(frameworkImageNamed: "remove")!.withRenderingMode(.alwaysTemplate)
    private let rightViewSize = CGSize(width: 40, height: 40)
    private let animationDuration: Double = 0.3

    private var underlineHeightConstraint: NSLayoutConstraint?

    private lazy var typeLabel: Label = {
        let label = Label(style: .title5(.licorice))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: clearTextIcon.size.width, height: clearTextIcon.size.height))
        button.setImage(clearTextIcon, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()

    private lazy var showPasswordButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: eyeImage.size.width, height: eyeImage.size.width))
        button.setImage(eyeImage, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
        return button
    }()

    private lazy var multilineDisclosureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: eyeImage.size.width, height: eyeImage.size.width))
        button.setImage(multilineDisclosureIcon, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(multilineDisclusureTapped), for: .touchUpInside)
        return button
    }()

    private lazy var textFieldBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ice
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var underline: UIView = {
        let view = UIView()
        view.backgroundColor = .stone
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var helpTextLabel: Label = {
        let label = Label(style: .detail(.licorice))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - External properties

    public lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.body
        textField.textColor = .licorice
        textField.tintColor = .secondaryBlue
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    public let inputType: InputType

    public var placeholderText: String = "" {
        didSet {
            typeLabel.text = placeholderText
            accessibilityLabel = placeholderText
            textField.placeholder = placeholderText
        }
    }

    public var text: String? {
        return textField.text
    }

    public var helpText: String? {
        didSet {
            helpTextLabel.text = helpText
        }
    }

    public weak var delegate: TextFieldDelegate?

    public var isValid: Bool {
        guard let text = textField.text else {
            return false
        }

        switch inputType {
        case .password:
            return isValidPassword(text)
        case .email:
            return isValidEmail(text)
        case .normal, .multiline:
            return true
        }
    }

    // MARK: - Setup

    public init(inputType: InputType) {
        self.inputType = inputType
        super.init(frame: .zero)
        setup()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(inputType: .email)
    }

    private func setup() {
        isAccessibilityElement = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        textField.isSecureTextEntry = inputType.isSecureMode
        textField.keyboardType = inputType.keyBoardStyle
        textField.returnKeyType = inputType.returnKeyType

        if inputType.isSecureMode {
            textField.rightViewMode = .always
            textField.rightView = showPasswordButton
        } else if case .multiline = inputType {
            textField.rightViewMode = .always
            textField.rightView = multilineDisclosureButton
        } else {
            textField.rightViewMode = .whileEditing
            textField.rightView = clearButton
        }

        addSubview(typeLabel)
        addSubview(textFieldBackgroundView)
        addSubview(textField)
        addSubview(underline)
        addSubview(helpTextLabel)

        NSLayoutConstraint.activate([
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: topAnchor),

            textFieldBackgroundView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: .mediumSpacing),
            textFieldBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textFieldBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: textFieldBackgroundView.topAnchor, constant: .mediumSpacing),
            textField.leadingAnchor.constraint(equalTo: textFieldBackgroundView.leadingAnchor, constant: .mediumSpacing),
            textField.trailingAnchor.constraint(equalTo: textFieldBackgroundView.trailingAnchor, constant: -.mediumSpacing),
            textField.bottomAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor, constant: -.mediumSpacing),

            underline.leadingAnchor.constraint(equalTo: leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor),

            helpTextLabel.topAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor, constant: .mediumSpacing),
            helpTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            helpTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            helpTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        underlineHeightConstraint = underline.heightAnchor.constraint(equalToConstant: UnderlineHeight.inactive.rawValue)
        underlineHeightConstraint?.isActive = true
    }

    // MARK: - Actions

    @objc private func showHidePassword(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            sender.imageView?.tintColor = .secondaryBlue
            textField.isSecureTextEntry = false
        } else {
            sender.imageView?.tintColor = .stone
            textField.isSecureTextEntry = true
        }

        textField.becomeFirstResponder()
    }

    @objc private func clearTapped() {
        textField.text = ""
        textFieldDidChange()
    }

    @objc private func multilineDisclusureTapped(sender: UIButton) {
        delegate?.textFieldDidTapMultilineAction(self)
    }

    @objc private func textFieldDidChange() {
        delegate?.textFieldDidChange(self)
    }

    @objc private func handleTap() {
        textField.becomeFirstResponder()
    }

    fileprivate func evaluate(_ regEx: String, with string: String) -> Bool {
        let regExTest = NSPredicate(format: "SELF MATCHES %@", regEx)
        return regExTest.evaluate(with: string)
    }

    fileprivate func isValidEmail(_ emailAdress: String) -> Bool {
        return evaluate("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", with: emailAdress)
    }

    fileprivate func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }

    private func animateUnderline(to height: UnderlineHeight, and color: UIColor) {
        layoutIfNeeded()
        underlineHeightConstraint?.constant = height.rawValue

        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
            self.underline.backgroundColor = color
        }
    }
}

// MARK: - UITextFieldDelegate

extension TextField: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch inputType {
        case .multiline:
            delegate?.textFieldDidTapMultilineAction(self)
            return false

        default: return true
        }
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
        animateUnderline(to: .active, and: .secondaryBlue)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(self)

        if let text = textField.text, !isValidEmail(text), !text.isEmpty, inputType == .email {
            animateUnderline(to: .inactive, and: .cherry)
        } else {
            animateUnderline(to: .inactive, and: .stone)
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(self) ?? true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
