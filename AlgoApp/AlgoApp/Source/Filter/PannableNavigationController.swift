//
//  NavigationController.swift
//  PanModal
//
//  Created by Stephen Sowole on 2/26/19.
//  Copyright © 2019 PanModal. All rights reserved.
//

import UIKit
import PanModal

class PannableNavigationController: UINavigationController, PanModalPresentable {

    // MARK: - Pan Modal Presentable

    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }

    var shortFormHeight: PanModalHeight {
        let height = UIScreen.main.bounds.size.height * 2 / 3
        return .contentHeight(height)
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }
}

