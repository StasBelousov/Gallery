//
//  PhotoCommentViewController.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

class PhotoCommentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
   
    private var activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private let imageService = ImageService()
    var images: [Image]?
    var imageIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicator()
        
        DispatchQueue.main.async {
            if let urlString = self.images?[self.imageIndex ?? 0].imageURL {
                self.imageService.download(at: urlString) { image in
                    guard let image = image else { return }
                    self.activityView.stopAnimating()
                    self.imageView.image = image
                }
            } else {
                self.imageView.image = UIImage.named("Photo")
                self.activityView.stopAnimating()
            }
        }
        imageNameLabel.text = images?[imageIndex ?? 0].name
    }
    
    private func showActivityIndicator() {
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier,
           let viewController = segue.destination as? ZoomedPhotoViewController,
           id == "zooming" {
            
            if let image = imageView.image {
                viewController.currentImage = image
            }
        }
    }
    
}

//MARK:- Actions
extension PhotoCommentViewController {
    
    @IBAction func openZoomingController(_ sender: AnyObject) {
        performSegue(withIdentifier: "zooming", sender: nil)
    }
    
    @IBAction func shareImageButton(_ sender: UIButton) {
        
        if let image = imageView.image {
            let imageToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.mail,
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.message]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

