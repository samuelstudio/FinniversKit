//
// Copyright (c) 2019 FINN AS. All rights reserved.
//

import UIKit

public protocol FullscreenGalleryViewControllerDataSource: class {
    func modelForFullscreenGalleryViewController(_ vc: FullscreenGalleryViewController) -> FullscreenGalleryViewModel
    func initialImageIndexForFullscreenGalleryViewController(_ vc: FullscreenGalleryViewController) -> Int
    func fullscreenGalleryViewController(_ vc: FullscreenGalleryViewController, loadImageAtIndex index: Int, dataCallback: @escaping (UIImage?) -> Void)
}

public protocol FullscreenGalleryViewControllerDelegate: class {

}

public class FullscreenGalleryViewController: UIPageViewController {

    // MARK: - Private properties

    private let captionFadeDuration = 0.2
    private let dismissButtonTitle = "Ferdig"

    private var viewModel: FullscreenGalleryViewModel?

    private lazy var captionLabel: Label = {
        let label = Label(style: .title4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .milk
        label.textAlignment = .center
        label.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.4)
        label.shadowOffset = CGSize(width: 1.0, height: 1.0);
        label.shadowColor = .black
        return label
    }()

    private lazy var dismissButton: UIButton = {
        let button = Button(style: .default)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        button.backgroundColor = .clear
        button.setTitle(dismissButtonTitle, for: .normal)
        return button
    }()

    private lazy var previewView: GalleryPreviewView = {
        let previewView = GalleryPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.delegate = self
        previewView.dataSource = self
        return previewView
    }()

    private var previewViewBottomConstraint: NSLayoutConstraint?
    private var previewViewVisible: Bool = true

    private lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(onSingleTap))
        recognizer.delegate = self
        return recognizer
    }()

    // MARK: - Public properties

    public weak var galleryDataSource: FullscreenGalleryViewControllerDataSource?
    public weak var galleryDelegate: FullscreenGalleryViewControllerDelegate?

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented: init(coder:)")
    }

    public override init(transitionStyle style: TransitionStyle, navigationOrientation: NavigationOrientation, options: [OptionsKey: Any]?) {
        fatalError("not implemented: init(transitionStyle:navigationOrientation:options:)")
    }

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.delegate = self
        self.dataSource = self
    }

    // MARK : - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(captionLabel)
        view.addSubview(dismissButton)
        view.addSubview(previewView)
        view.addGestureRecognizer(singleTapGestureRecognizer)

        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }

        previewViewBottomConstraint = previewView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            captionLabel.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            captionLabel.widthAnchor.constraint(lessThanOrEqualTo: layoutGuide.widthAnchor, constant: -(2 * .mediumLargeSpacing)),
            captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutGuide.bottomAnchor, constant: -.mediumSpacing),
            captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: previewView.topAnchor, constant: -.mediumSpacing),

            dismissButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -.mediumLargeSpacing),
            dismissButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: .mediumLargeSpacing),

            previewViewBottomConstraint!,
            previewView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])

        viewModel = galleryDataSource?.modelForFullscreenGalleryViewController(self)
        previewView.viewModel = viewModel

        let initialImageIndex = galleryDataSource?.initialImageIndexForFullscreenGalleryViewController(self) ?? 0
        setCaptionLabel(index: initialImageIndex)

        if let imageController = imageViewController(forIndex: initialImageIndex) {
            setViewControllers([imageController], direction: .forward, animated: false)
        }
    }

    // MARK: - Private methods

    @objc private func dismissButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func onSingleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if previewViewVisible {
            previewViewBottomConstraint?.constant = previewView.bounds.height
            previewViewVisible = false
        } else {
            previewViewBottomConstraint?.constant = 0
            previewViewVisible = true
        }

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func setCaptionLabel(index: Int) {
        let caption: String? = {
            if index >= 0 && index < viewModel?.imageCaptions.count ?? 0 {
                return viewModel?.imageCaptions[index]
            } else {
                return nil
            }
        }()

        UIView.transition(with: captionLabel, duration: captionFadeDuration, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.captionLabel.text = caption
        })
    }
}

// MARK: - UIPageViewControllerDataSource
extension FullscreenGalleryViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let imageController = viewController as? FullscreenImageViewController {
            return imageViewController(forIndex: imageController.imageIndex - 1)
        }

        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let imageController = viewController as? FullscreenImageViewController {
            return imageViewController(forIndex: imageController.imageIndex + 1)
        }

        return nil
    }

    private func imageViewController(forIndex index: Int) -> FullscreenImageViewController? {
        if index < 0 || index >= viewModel?.imageUrls.count ?? 0 {
            return nil
        }

        return FullscreenImageViewController(imageIndex: index, dataSource: self)
    }
}

// MARK: - UIPageViewControllerDelegate
extension FullscreenGalleryViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let imageVc = pageViewController.viewControllers?.first as? FullscreenImageViewController else {
            return
        }

        setCaptionLabel(index: imageVc.imageIndex)
    }
}

// MARK: - UIGesture
extension FullscreenGalleryViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UITapGestureRecognizer
    }
}

// MARK: - FullscreenImageViewControllerDataSource
extension FullscreenGalleryViewController: FullscreenImageViewControllerDataSource {
    func loadImage(forImageViewController vc: FullscreenImageViewController, dataCallback: @escaping (UIImage?) -> Void) {
        // TODO: Unify with GalleryPreviewViewDataSource loading, prevent double fetching images!!
        guard galleryDataSource != nil else {
            dataCallback(nil)
            return
        }

        galleryDataSource!.fullscreenGalleryViewController(self, loadImageAtIndex: vc.imageIndex, dataCallback: dataCallback)
    }

    func title(forImageViewController vc: FullscreenImageViewController) -> String? {
        if let captions = viewModel?.imageCaptions {
            if vc.imageIndex < 0 || vc.imageIndex >= captions.count {
                return nil
            }

            return captions[vc.imageIndex]
        }

        return nil
    }
}

// MARK: - GalleryPreviewViewDataSource
extension FullscreenGalleryViewController: GalleryPreviewViewDataSource {
    func loadImage(withIndex index: Int, dataCallback: @escaping (Int, UIImage?) -> Void) {
        // TODO: Unify with FullscreenImageViewControllerDataSource loading, prevent double fetching images!!
        guard galleryDataSource != nil else {
            dataCallback(index, nil)
            return
        }

        galleryDataSource!.fullscreenGalleryViewController(self, loadImageAtIndex: index, dataCallback: { image in
            dataCallback(index, image)
        })
    }
}

// MARK: - GalleryPreviewViewDelegate
extension FullscreenGalleryViewController: GalleryPreviewViewDelegate {
    func galleryPreviewView(_ previewView: GalleryPreviewView, selectedImageAtIndex index: Int) {
        print("Collection view selected item at index: \(index)")
    }
}
