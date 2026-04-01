//
//  MoviesListViewController.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit
import Combine

final class MoviesListViewController: UIViewController {
    
    enum Section: Hashable {
        case movies
    }
    
    private let viewModel: MoviesListViewModel
    private weak var coordinator: MoviesCoordinator?
    private var cancellables = Set<AnyCancellable>()
    var dataSource: UICollectionViewDiffableDataSource<Section, Movie>?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    
    private let loadingView = UILoadingView()
    private let errorView = UIErrorView()
    
    init(viewModel: MoviesListViewModel, coordinator: MoviesCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        bindViewModel()
        viewModel.fetchPopularMovies()
    }
    
    private func setupUI() {
        title = "Popular Movies"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.isHidden = true
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.onRetry = { [weak self] in
            self?.viewModel.retry()
        }
        
        view.addSubview(collectionView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$movies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.applySnapshot(movies: movies)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if !isLoading {
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: ViewState<[Movie]>) {
        switch state {
        case .idle:
            break
            
        case .loading:
            if viewModel.movies.isEmpty {
                loadingView.start()
                collectionView.isHidden = true
            }
            errorView.isHidden = true
            
        case .success:
            loadingView.stop()
            errorView.isHidden = true
            collectionView.isHidden = false
            collectionView.refreshControl?.endRefreshing()
            
        case .failure(let error):
            loadingView.stop()
            collectionView.refreshControl?.endRefreshing()
            
            if viewModel.movies.isEmpty {
                errorView.configure(message: error.errorDescription ?? "Unknown error")
                errorView.isHidden = false
                collectionView.isHidden = true
            } else {
                showErrorBanner(message: error.errorDescription ?? "Failed to load more movies")
            }
        }
    }
    
    @objc private func pullToRefresh() {
        viewModel.fetchPopularMovies()
    }
    
    private func showErrorBanner(message: String) {
        let banner = UILabel()
        banner.text = message
        banner.textColor = .white
        banner.backgroundColor = .systemRed
        banner.textAlignment = .center
        banner.font = .systemFont(ofSize: 14)
        banner.layer.cornerRadius = 8
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.alpha = 0
        
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            banner.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        UIView.animate(withDuration: 0.3, animations: { banner.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 3.0, animations: { banner.alpha = 0 }) { _ in
                banner.removeFromSuperview()
            }
        }
    }
}

extension MoviesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let movie = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        coordinator?.showMovieDetail(movieId: movie.id)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.item)
    }
}
