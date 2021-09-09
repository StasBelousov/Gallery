//
//  ViewController.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var gallerySearchBar: UISearchBar!
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private var refreshControl = UIRefreshControl()
    private let imageService = ImageService()
    private var actualImageList: [Image] = []
    private var filteredImageList: [Image] = []
    private var searchBarIsEmpty: Bool {
        guard let text = gallerySearchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return !searchBarIsEmpty
    }
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let interitemSpacing: CGFloat = 10
    private var currentIndexPath: IndexPath?
    private let pressedDownTransform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        gallerySearchBar.delegate = self
        gallerySearchBar.delegate = self
        fetchImages()
        addLongClick()
        refreshControl.addTarget(self, action: #selector(handleTopRefresh(_:)), for: .valueChanged )
        galleryCollectionView.refreshControl = refreshControl
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell,
           let indexPath = galleryCollectionView?.indexPath(for: cell),
           let managePageViewController = segue.destination as? ManagePageViewController {
            managePageViewController.images = isFiltering ? filteredImageList : actualImageList
            managePageViewController.currentIndex = indexPath.row
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    //MARK: Data request
    private func fetchImages() {
        APIService.shared.fetchImages() { [weak self] fetchResult in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch fetchResult {
                case .success(let gallery):
                    self.actualImageList.append(contentsOf: gallery)
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription, actions: nil )
                }
                self.galleryCollectionView.refreshControl?.endRefreshing()
                self.galleryCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - Image Data funcs
    func saveImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
    
    //MARK: User interactions funcs
    func addLongClick() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTapLongPress))
        longPressRecognizer.minimumPressDuration = 0.05
        longPressRecognizer.cancelsTouchesInView = false
        galleryCollectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func animate(_ cell: UICollectionViewCell, to transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.05,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 2,
                       options: [.curveEaseInOut],
                       animations: {
                        cell.transform = transform
                       }, completion: nil)
    }
    
    func searchBarShouldReturn(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gallerySearchBar.endEditing(true)
    }
    
    //MARK: Actions
    @objc
    func handleTopRefresh(_ sender: UIRefreshControl) {
        actualImageList.removeAll()
        galleryCollectionView.reloadData()
        fetchImages()
        sender.endRefreshing()
    }
    
    @objc
    func didTapLongPress(sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: galleryCollectionView)
        let indexPath = galleryCollectionView.indexPathForItem(at: point)
        
        if sender.state == .began,
           let indexPath = indexPath,
           let cell = galleryCollectionView.cellForItem(at: indexPath) {
            animate(cell, to: pressedDownTransform)
            self.currentIndexPath = indexPath
        } else if sender.state == .changed {
            if indexPath != self.currentIndexPath,
               let currentIndexPath = self.currentIndexPath,
               let cell = galleryCollectionView.cellForItem(at: currentIndexPath) {
                if cell.transform != .identity {
                    animate(cell, to: .identity)
                }
            } else if indexPath == self.currentIndexPath,
                      let indexPath = indexPath,
                      let cell = galleryCollectionView.cellForItem(at: indexPath) {
                if cell.transform != pressedDownTransform {
                    animate(cell, to: pressedDownTransform)
                }
            }
        } else if let currentIndexPath = currentIndexPath,
                  let cell = galleryCollectionView.cellForItem(at: currentIndexPath) {
            animate(cell, to: .identity)
            self.currentIndexPath = nil
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imageList = isFiltering ? filteredImageList.count : actualImageList.count
        return imageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? GalleryCollectionViewCell else {
            fatalError("Collection View Cell class not found.")
        }
        let thumbnail: Image = isFiltering ? filteredImageList[indexPath.row] : actualImageList[indexPath.row]
        
        if let currentThumbnail = loadImageFromDiskWith(fileName: thumbnail.name) {
            cell.setUI(image: currentThumbnail, name: thumbnail.name)
        } else {
            DispatchQueue.main.async {
                if let urlString = thumbnail.thumbnailURL {
                    self.imageService.download(at: urlString) { image in
                        guard let image = image else { return }
                        self.saveImage(imageName: thumbnail.name, image: image)
                        cell.setUI(image: image, name: thumbnail.name)
                    }
                } else {
                    cell.setUI(image: UIImage.named("Photo"), name: thumbnail.name)
                }
            }
        }
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItems: CGFloat = 4
        let sectionWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        let width = (sectionWidth - interitemSpacing * (numberOfItems - 1)) / numberOfItems
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
}

//MARK: - SearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredImageList = actualImageList.filter({ (image: Image) -> Bool in
            return image.name.lowercased().contains(searchText.lowercased())
        })
        print(filteredImageList)
        galleryCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

