//
//  MovieCell.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

final class MovieCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MovieCell"
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel = UILabel.makeLabel(
        font: .systemFont(ofSize: 15, weight: .semibold),
        numberOfLines: 2,
        textColor: .label
    )
    
    private let yearLabel = UILabel.makeLabel(
        font: .systemFont(ofSize: 13, weight: .regular),
        textColor: .secondaryLabel
    )
    
    private let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow.withAlphaComponent(0.15)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let ratingLabel = UILabel.makeLabel(
        font: .systemFont(ofSize: 13, weight: .bold),
        textColor: .systemOrange
    )
    
    
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        let iv = UIImageView(image: UIImage(systemName: "film"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 40),
            iv.heightAnchor.constraint(equalToConstant: 40)
        ])
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageLoadTask?.cancel()
        posterImageView.image = nil
        placeholderView.isHidden = false
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.formattedReleaseYear
        ratingLabel.text = movie.formattedRating
        
        loadImage(from: movie.posterURL)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
        
        contentView.addSubview(placeholderView)
        contentView.addSubview(posterImageView)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, yearLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingStack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        
        ratingView.addSubview(ratingStack)
        
        let bottomStack = UIStackView(arrangedSubviews: [textStack, UIView(), ratingView])
        bottomStack.axis = .horizontal
        bottomStack.alignment = .center
        bottomStack.spacing = 8
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bottomStack)
        
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeholderView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.4),
            
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.4),
            
            bottomStack.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bottomStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bottomStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            starImageView.widthAnchor.constraint(equalToConstant: 12),
            starImageView.heightAnchor.constraint(equalToConstant: 12),
            
            ratingStack.topAnchor.constraint(equalTo: ratingView.topAnchor, constant: 4),
            ratingStack.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 6),
            ratingStack.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -6),
            ratingStack.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: -4),
        ])
    }
    
    private func loadImage(from url: URL?) {
        guard let url else { return }
        
        imageLoadTask = Task { [weak self] in
            let image = await ImageLoader.shared.loadImage(from: url)
            
            guard !Task.isCancelled, let self else { return }
            
            await MainActor.run {
                self.placeholderView.isHidden = true
                self.posterImageView.image = image
                UIView.transition(
                    with: self.posterImageView,
                    duration: 0.25,
                    options: .transitionCrossDissolve,
                    animations: nil
                )
            }
        }
    }}
