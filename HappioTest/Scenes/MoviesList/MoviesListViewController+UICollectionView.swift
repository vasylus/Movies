//
//  MoviesListViewController+DataSource.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

extension MoviesListViewController {

    func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Movie>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, movie: Movie) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCell.reuseIdentifier,
                for: indexPath
            ) as? MovieCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: movie)
            return cell
        }
    }
    
    func applySnapshot(movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        snapshot.appendSections([.movies])
        snapshot.appendItems(movies, toSection: .movies)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
