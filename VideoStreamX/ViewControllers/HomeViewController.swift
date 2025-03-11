//
//  HomeViewController.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import UIKit
import SnapKit
import Combine

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private var cancellable = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: VideoTableViewCell.identifier)
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(viewModel: HomeViewModel = HomeViewModel(service: GoogleVideoService())) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        binding()
    }

    private func setupUI() {
        title = "Video Stream X"
        view.addSubview(tableView)
        tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }

    private func binding() {
        viewModel.$videos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = viewModel.videos[indexPath.row]
        let playerViewController = PlayerViewController(video: video)
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true)
//        navigationController?.pushViewController(playerViewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier,
                                                       for: indexPath) as? VideoTableViewCell else { return UITableViewCell() }

        cell.configure(with: viewModel.videos[indexPath.row])
        return cell
    }
}
