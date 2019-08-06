//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class FavoriteAdsSectionHeaderView: UITableViewHeaderFooterView {

    // MARK: - Private properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = .detailStrong
        label.textColor = .stone
        return label
    }()

    // MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing)
        ])
    }

    // MARK: - Internal methods

    func configure(title: String) {
        titleLabel.text = title.uppercased()
    }
}