//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

public class RecommendationsViewDemoView: UIView {
    private var didSetupView = false
    private var visibleItems = 20

    private let ads: [Ad] = {
        var ads = AdFactory.create(numberOfModels: 120)
        ads.insert(AdFactory.googleDemoAd, at: 4)
        return ads
    }()

    private lazy var recommendationsView: RecommendationsView = {
        let view = RecommendationsView(delegate: self)
        view.model = RecommendationsViewDefaultData()
        view.isRefreshEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Setup

    public override func layoutSubviews() {
        super.layoutSubviews()

        if didSetupView == false {
            setup()
            didSetupView = true
        }
    }

    private func setup() {
        addSubview(recommendationsView)
        recommendationsView.fillInSuperview()
        recommendationsView.reloadData()
    }
}

// MARK: - AdsGridViewDelegate

extension RecommendationsViewDemoView: RecommendationsViewDelegate {
    public func recommendationsViewDidSelectRetryButton(_ recommendationsView: RecommendationsView) {
        recommendationsView.reloadData()
    }
}

extension RecommendationsViewDemoView: AdsGridViewDelegate {
    public func adsGridView(_ adsGridView: AdsGridView, willDisplayItemAtIndex index: Int) {
        if index >= visibleItems - 10 {
            visibleItems += 10

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.recommendationsView.reloadAds()
            })
        }
    }

    public func adsGridView(_ adsGridView: AdsGridView, didScrollInScrollView scrollView: UIScrollView) {}
    public func adsGridView(_ adsGridView: AdsGridView, didSelectItemAtIndex index: Int) {}

    public func adsGridViewDidStartRefreshing(_ adsGridView: AdsGridView) {
        recommendationsView.reloadData()
    }

    public func adsGridView(_ adsGridView: AdsGridView, didSelectFavoriteButton button: UIButton, on cell: AdsGridViewCell, at index: Int) {
        adsGridView.updateItem(at: index, isFavorite: !cell.isFavorite)
    }
}

// MARK: - AdsGridViewDataSource

extension RecommendationsViewDemoView: AdsGridViewDataSource {
    public func numberOfItems(inAdsGridView adsGridView: AdsGridView) -> Int {
        return min(ads.count, visibleItems)
    }

    public func adsGridView(_ adsGridView: AdsGridView, cellClassesIn collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
        return [
            AdsGridViewCell.self,
            BannerAdDemoCell.self
        ]
    }

    public func adsGridView(_ adsGridView: AdsGridView, heightForItemWithWidth width: CGFloat, at indexPath: IndexPath) -> CGFloat {
        let model = ads[indexPath.item]

        switch model.adType {
        case .google:
            return 300
        default:
            return AdsGridViewCell.height(
                for: model,
                width: width
            )
        }
    }

    public func adsGridView(_ adsGridView: AdsGridView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = ads[indexPath.item]

        switch model.adType {
        case .google:
            return collectionView.dequeue(BannerAdDemoCell.self, for: indexPath)

        default:
            let cell = collectionView.dequeue(AdsGridViewCell.self, for: indexPath)
            cell.dataSource = adsGridView
            cell.delegate = adsGridView
            cell.configure(with: model, atIndex: indexPath.item)
            return cell
        }
    }

    public func adsGridView(_ adsGridView: AdsGridView, loadImageWithPath imagePath: String, imageWidth: CGFloat, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: imagePath) else {
            completion(nil)
            return
        }

        // Demo code only.
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            usleep(50_000)
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }

        task.resume()
    }

    public func adsGridView(_ adsGridView: AdsGridView, cancelLoadingImageWithPath imagePath: String, imageWidth: CGFloat) {}
}

// MARK: - DialogueViewDelegate

extension RecommendationsViewDemoView: DialogueViewDelegate {
    public func dialogueViewDidSelectLink() {}
    public func dialogueViewDidSelectPrimaryButton() {
        recommendationsView.hideInlineConsent()
        recommendationsView.reloadAds()
    }
}
