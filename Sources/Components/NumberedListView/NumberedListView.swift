//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import Foundation

public protocol NumberedListViewDelegate: AnyObject {
    func numberedListView(_ numberedListView: NumberedListView, textForStep step: Int) -> String
}

public class NumberedListView: UIView {
    public weak var delegate: NumberedListViewDelegate?

    private let numberOfSteps: Int

    // MARK: - Init

    public init(numberOfSteps: Int, delegate: NumberedListViewDelegate, withAutoLayout autoLayout: Bool = false) {
        self.numberOfSteps = numberOfSteps
        self.delegate = delegate

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = !autoLayout
        setup()
    }

    public required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .bgTertiary
        layer.cornerRadius = .mediumSpacing

        guard let bodyText = delegate?.numberedListView(self, textForStep: 0) else { return }
        let view = NumberedLabelView(number: 0, bodyText: bodyText, withAutoLayout: true)

        addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
