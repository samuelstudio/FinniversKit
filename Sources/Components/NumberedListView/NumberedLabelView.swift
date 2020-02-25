//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import Foundation

public class NumberedLabelView: UIView {
    private lazy var numberLabel: Label = {
        let label = Label(style: .bodyStrong, withAutoLayout: true)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var bodyView: UITextView = {
        let view = UITextView(withAutoLayout: true)
        view.font = .body
        view.textColor = .licorice
        view.backgroundColor = .bgTertiary
        view.contentMode = .bottomLeft
        view.isScrollEnabled = false
        view.isEditable = false
        view.adjustsFontForContentSizeCategory = true
        return view
    }()

    init(number: Int, bodyText: String, withAutoLayout autoLayout: Bool = false) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = !autoLayout

        numberLabel.text = "\(number)."
        bodyView.text = bodyText

        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup() {
        addSubview(numberLabel)
        addSubview(bodyView)

        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor)
        ])
    }
}
