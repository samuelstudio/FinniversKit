//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol RecommendationsViewModel {
    var headerTitle: String { get }
    var retryButtonTitle: String { get }
    var noRecommendationsText: String { get }
    var inlineConsentDialogueViewModel: DialogueViewModel { get }
}

public protocol RecommendationsViewDelegate: AnyObject {
    func recommendationsViewDidSelectRetryButton(_ recommendationsView: RecommendationsView)
}

public final class RecommendationsView: UIView {
    public var model: RecommendationsViewModel? {
        didSet {
            headerLabel.text = model?.headerTitle
            adsRetryView.set(labelText: model?.noRecommendationsText, buttonText: model?.retryButtonTitle)
            inlineConsentDialogue.model = model?.inlineConsentDialogueViewModel
        }
    }

    public var isRefreshEnabled: Bool {
        get {
            return adsGridView.isRefreshEnabled
        }
        set {
            adsGridView.isRefreshEnabled = newValue
        }
    }

    private weak var delegate: RecommendationsViewDelegate?
    private var didSetupView = false

    // MARK: - Subviews

    public let adsGridView: AdsGridView
    private lazy var headerView = UIView()

    private lazy var inlineConsentDialogue: DialogueView = {
        let dialogueView = DialogueView()
        dialogueView.dropShadow(color: .iconPrimary)
        dialogueView.isHidden = true
        return dialogueView
    }()

    //Use this do disable all ads :D
    private lazy var inlineConsentLockView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        view.isHidden = true
        return view
    }()

    private lazy var headerLabel: Label = {
        var headerLabel = Label(style: .title3)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        return headerLabel
    }()

    private lazy var adsRetryView: FrontPageRetryView = {
        let view = FrontPageRetryView()
        view.delegate = self
        return view
    }()

    private var keyValueObservation: NSKeyValueObservation?

    private var boundsForCurrentSubviewSetup = CGRect.zero

    // MARK: - Init

    public convenience init(delegate: RecommendationsViewDelegate & AdsGridViewDelegate & AdsGridViewDataSource & DialogueViewDelegate) {
        self.init(delegate: delegate, adsGridViewDelegate: delegate, adsGridViewDataSource: delegate, inlineConsentDialogueViewDelegate: delegate)
    }

    public init(delegate: RecommendationsViewDelegate, adsGridViewDelegate: AdsGridViewDelegate, adsGridViewDataSource: AdsGridViewDataSource, inlineConsentDialogueViewDelegate: DialogueViewDelegate) {
        adsGridView = AdsGridView(delegate: adsGridViewDelegate, dataSource: adsGridViewDataSource)
        adsGridView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        self.delegate = delegate
        inlineConsentDialogue.delegate = inlineConsentDialogueViewDelegate
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        keyValueObservation?.invalidate()
    }

    // MARK: - Overrides

    public override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        return CGSize(
            width: targetSize.width,
            height: CGFloat(500)
        )
    }

    // MARK: - Public

    public override func layoutSubviews() {
        super.layoutSubviews()

        if didSetupView == false {
            setup()
            didSetupView = true
        } else if !boundsForCurrentSubviewSetup.equalTo(bounds) {
            setupFrames()
        }
    }

    public func reloadData() {
        setupFrames()
        reloadAds()
    }

    public func reloadMarkets() {
        setupFrames()
        adsGridView.reloadData()
    }

    public func reloadAds() {
        adsRetryView.state = .hidden
        adsGridView.reloadData()
    }

    public func updateAd(at index: Int, isFavorite: Bool) {
        adsGridView.updateItem(at: index, isFavorite: isFavorite)
    }

    public func showAdsRetryButton() {
        adsGridView.endRefreshing()
        adsRetryView.state = .labelAndButton
    }

    public func showInlineConsent(detail: String? = nil) {
        if let detail = detail {
            inlineConsentDialogue.model?.detail = detail
        }

        inlineConsentDialogue.isHidden = false
        inlineConsentLockView.isHidden = false
        adsGridView.endRefreshing()
        setupFrames()
    }

    public func hideInlineConsent() {
        inlineConsentDialogue.isHidden = true
        inlineConsentLockView.isHidden = true
        adsGridView.endRefreshing()
    }

    public func scrollToTop() {
        adsGridView.scrollToTop()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .bgPrimary

        addSubview(adsGridView)

        adsGridView.collectionView.addSubview(adsRetryView)
        adsGridView.collectionView.addSubview(inlineConsentLockView)
        adsGridView.collectionView.addSubview(inlineConsentDialogue)

        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: .mediumLargeSpacing),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: .mediumLargeSpacing),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -.mediumLargeSpacing),
            headerLabel.heightAnchor.constraint(equalToConstant: 67)
        ])

        adsGridView.fillInSuperview()
        adsGridView.headerView = headerView

        setupFrames()
    }

    private func setupFrames() {
        let headerTopSpacing: CGFloat = .mediumLargeSpacing
        let headerBottomSpacing: CGFloat = .mediumSpacing
        let labelHeight = headerLabel.intrinsicContentSize.height + .mediumLargeSpacing
        let height = headerTopSpacing + labelHeight + headerBottomSpacing

        headerView.frame.size.height = height
        adsRetryView.frame.origin = CGPoint(x: 0, y: headerView.frame.height + .veryLargeSpacing)
        adsRetryView.frame.size = CGSize(width: bounds.width, height: 200)
        boundsForCurrentSubviewSetup = bounds
        adsGridView.invalidateLayout()
        setupFrameForDialogue(yPosition: height)
    }

    func setupFrameForDialogue(yPosition: CGFloat) {
        var widthPercentage: CGFloat = 0.8
        var heightPercentage: CGFloat = 0.3

        if UIDevice.isSmallScreen() {
            widthPercentage = 0.9
            heightPercentage = 0.5
        }

        if UIDevice.isIPad() {
            widthPercentage = 0.5
            heightPercentage = 0.22

            if UIDevice.isLargeScreen() {
                heightPercentage = 0.16
            }
        }

        let dialogueWidth = bounds.width * widthPercentage
        let dialogueHeight = (bounds.height * heightPercentage) +
            inlineConsentDialogue.heightWithConstrained(width: dialogueWidth)
        let inlineConsentDialogueY = yPosition + 25

        inlineConsentDialogue.frame = CGRect(
            x: (bounds.width - dialogueWidth) / 2,
            y: inlineConsentDialogueY,
            width: dialogueWidth,
            height: dialogueHeight)

        inlineConsentLockView.frame = CGRect(
            x: 0,
            y: yPosition,
            width: bounds.width,
            height: bounds.height * 2)
        //we really dont know what the height of lock view should be since some ads are longer then other.
    }
}

// MARK: - FrontpageRetryViewDelegate

extension RecommendationsView: FrontPageRetryViewDelegate {
    func frontPageRetryViewDidSelectButton(_ view: FrontPageRetryView) {
        adsRetryView.state = .loading
        delegate?.recommendationsViewDidSelectRetryButton(self)
    }
}
