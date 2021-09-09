//
//  UIViewController+Extension.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actionsArray = actions, !actionsArray.isEmpty {
            for action in actionsArray {
                alertController.addAction(action)
            }
        } else {
            let alertAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(alertAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

