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
        self.textLabel.setTextColor(self.getUIColor(title))
        self.detailLabel.setText(detail)
        self.detailLabel.setTextColor(self.getUIColor(title))
    }
    
    func getUIColor(title: String)->UIColor {
        if (title == "green") { return UIColor(red: 0.0, green: 255.0/255, blue: 0.0, alpha: 1.0) }
        if (title == "orange") { return UIColor(red: 247.0/255, green: 107.0/255, blue: 9.0/255, alpha: 1.0) }
        return UIColor(red: 255.0/255, green: 0.0, blue: 6.0/255, alpha: 1.0)
    }
}
