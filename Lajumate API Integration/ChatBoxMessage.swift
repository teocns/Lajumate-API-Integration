//
//  ChatBoxMessage.swift
//  Lajumate API Integration
//
//  Created by Doru Constantin Teodorescu on 2/12/20.
//  Copyright © 2020 Doru Constantin Teodorescu. All rights reserved.
//

import Foundation

import UIKit


class ChatBoxMessage : UIViewController{
    
    let labelFont = UIFont.systemFontSize()
    let labelText : String? = "Just add the property ColorLiteral as shown in the example, Xcode will prompt you with a whole list of colors which you can choose. The advantage of doing so is lesser code, add HEX values or RGB. You will also get the recently used colors from the storyboard."
    let containerViewHeight : CGFloat = ChatBoxMessage.Height(text:labelText, font: labelFont, width: view.frame.width)
    
    var containerView : UIView {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xF8BBD0)
        return view
    }
    
    var label : UILabel {
        let label = UILabel()
        label.numberOfLines=0
        return label
    }
    

    
    static func Height(text:String?, font: UIFont, width: CGFloat) -> CGFloat{
        
        var currentHeight : CGFloat!
        
        let label = UILabel(frame:CGRect(x:0, y:0,width:width,height: CGFloat.max))
        
        label.text = text
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = font
        label.lineBreakMode = .ByWordWrapping
        currentHeight = label.frame.height
        label.removeFromSuperview()
        return currentHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(rgb: 0xF8BBD0)
        
        view.addSubview(containerView)
        view.addSubview(label)
        

        
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}