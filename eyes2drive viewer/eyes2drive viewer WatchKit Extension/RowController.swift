//
//  RowController.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 24/09/15.
//  Copyright © 2015 Focusdays2015. All rights reserved.
//

import WatchKit


class RowController: NSObject {
    
    @IBOutlet weak var textLabel: WKInterfaceLabel!
    @IBOutlet weak var detailLabel: WKInterfaceLabel!
    
    func showItem(title: String, detail: String) {
        
        self.textLabel.setText(title)
        self.detailLabel.setText(detail)
    }
}
