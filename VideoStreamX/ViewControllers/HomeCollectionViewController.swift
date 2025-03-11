//
//  HomeCollectionViewController.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/9.
//

import UIKit
import SnapKit
import Combine

class HomeCollectionViewController: UIViewController {
    private let viewModel: HomeViewModel
    private var cancellable = Set<AnyCancellable>()

    enum LayoutType {
        case portrait  // 豎屏: 一行一個
        case landscape // 橫屏: 一行多個
    }
    private var currentLayoutType: LayoutType = .portrait

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout(for: currentLayoutType)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    init(viewModel: HomeViewModel = HomeViewModel(service: OthersVideoService())) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        title = "Video Stream X"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })

        let orientation = UIDevice.current.orientation
        updateLayoutForCurrentOrientation(isPortrait: orientation.isPortrait)
    }

    private func binding() {
        viewModel.$videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
    }
}

extension HomeCollectionViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateLayoutForCurrentOrientation(isPortrait: size.height > size.width)
        })
    }

    private func createLayout(for layoutType: LayoutType) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(layoutType == .portrait ? 1.0 : 0.5),
            heightDimension: .estimated(180)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func updateLayoutForCurrentOrientation(isPortrait: Bool) {
        // 根據當前方向更新佈局
        let newLayoutType: LayoutType = isPortrait ? .portrait : .landscape

        if currentLayoutType != newLayoutType {
            currentLayoutType = newLayoutType
            collectionView.setCollectionViewLayout(createLayout(for: currentLayoutType), animated: true)
        }
    }
}

extension HomeCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier,
                                                            for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewModel.videos[indexPath.item])
        return cell
    }
    
}

extension HomeCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.item]
        let playerViewController = PlayerViewController(video: video)
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true)
    }
}
