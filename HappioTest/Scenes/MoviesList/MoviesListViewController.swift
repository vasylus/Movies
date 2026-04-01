//
//  MoviesListViewController.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit
import Combine

final class MoviesListViewController: UIViewController {
    
    private let viewModel: MoviesListViewModel
    private weak var coordinator: MoviesCoordinator?
    private var cancellables = Set<AnyCancellable>()
    var dataSource: UICollectionViewDiffableDataSource<Section, Movie>?
    
    lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        cv.delegate = self
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private lazy var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "wifi.exclamationmark"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Something went wrong"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorTitleLabel = titleLabel
        
        let messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.errorMessageLabel = messageLabel
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 12
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel, retryButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            retryButton.widthAnchor.constraint(equalToConstant: 160),
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
        return view
    }()
    
    private let footerLoadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var errorTitleLabel: UILabel?
    private var errorMessageLabel: UILabel?
    
    enum Section: Hashable {
        case movies
    }
    
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
                if isLoading {
                    self?.footerLoadingView.startAnimating()
                } else {
                    self?.footerLoadingView.stopAnimating()
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: ViewState<[Movie]>) {
        switch state {
        case .idle:
            break
        case .loading:
            loadingView.isHidden = false
            errorView.isHidden = true
            collectionView.isHidden = true
            
        case .success:
            loadingView.isHidden = true
            errorView.isHidden = true
            collectionView.isHidden = false
            collectionView.refreshControl?.endRefreshing()
            
        case .failure(let error):
            loadingView.isHidden = true
            collectionView.refreshControl?.endRefreshing()
            
            if viewModel.movies.isEmpty {
                errorView.isHidden = false
                collectionView.isHidden = true
                errorMessageLabel?.text = error.errorDescription
            } else {
                // Show toast/banner for pagination error
                showErrorBanner(message: error.errorDescription ?? "Failed to load more movies")
            }
        }
    }
    
    @objc private func retryTapped() {
        viewModel.retry()
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
