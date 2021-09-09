//
//  ManagePageViewController.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

class ManagePageViewController: UIPageViewController {
    
    var images: [Image] = []
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = viewPhotoCommentController(currentIndex ?? 0) {
            let viewControllers = [viewController]
            
            setViewControllers(viewControllers,
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        
        dataSource = self
    }
    
    func viewPhotoCommentController(_ index: Int) -> PhotoCommentViewController? {
        guard
            let storyboard = storyboard,
            let page = storyboard.instantiateViewController(withIdentifier: "PhotoCommentViewController") as? PhotoCommentViewController
        
        else {
            return nil
        }
        page.images = images
        page.imageIndex = index
        return page
    }
    
}

extension ManagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? PhotoCommentViewController,
           let index = viewController.imageIndex,
           index > 0 {
            
            return viewPhotoCommentController(index - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? PhotoCommentViewController,
           let index = viewController.imageIndex,
           (index + 1) < images.count {
            return viewPhotoCommentController(index + 1)
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex ?? 0
    }
    
}

