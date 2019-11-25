//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol BuyerPickerCellDelegate: AnyObject {
    func buyerPickerCellDefaultPlaceholderImage(_ cell: BuyerPickerProfileCell) -> UIImage?
    func buyerPickerCell(_ cell: BuyerPickerProfileCell, loadImageForModel model: BuyerPickerProfileModel, imageWidth: CGFloat, completion: @escaping ((UIImage?) -> Void))
    func buyerPickerCell(_ cell: BuyerPickerProfileCell, cancelLoadingImageForModel model: BuyerPickerProfileModel, imageWidth: CGFloat)
}

class BuyerPickerProfileCell: UITableViewCell {
    static let profileImageSize: CGFloat = 44

    lazy var profileImage: RoundedImageView = {
        let image = RoundedImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    lazy var name: Label = {
        let label = Label(style: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var hairlineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .bgSecondary
        return view
    }()

    var model: BuyerPickerProfileModel? {
        didSet {
            name.text = model?.name ?? ""
        }
    }

    weak var delegate: BuyerPickerCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    private func setup() {
        accessoryType = .disclosureIndicator

        let profileStack = UIStackView(arrangedSubviews: [profileImage, name])
        profileStack.alignment = .center
        profileStack.spacing = .mediumSpacing
        profileStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(profileStack)
        contentView.addSubview(hairlineView)

        NSLayoutConstraint.activate([
            profileStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .mediumSpacing),
            profileStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing),
            profileStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumLargeSpacing),
            profileStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),

            profileImage.heightAnchor.constraint(equalToConstant: BuyerPickerProfileCell.profileImageSize),
            profileImage.widthAnchor.constraint(equalToConstant: BuyerPickerProfileCell.profileImageSize),

            hairlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hairlineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumSpacing),
            hairlineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumSpacing),
            hairlineView.heightAnchor.constraint(equalToConstant: 2)
        ])

        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
        name.text = ""

        if let model = model {
            delegate?.buyerPickerCell(self, cancelLoadingImageForModel: model, imageWidth: BuyerPickerProfileCell.profileImageSize)
        }
    }

    func loadImage() {
        profileImage.image = delegate?.buyerPickerCellDefaultPlaceholderImage(self)
        guard let model = model else { return }
        delegate?.buyerPickerCell(self, loadImageForModel: model, imageWidth: BuyerPickerProfileCell.profileImageSize, completion: { [weak self] image in
            if let image = image {
                self?.profileImage.image = image
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}