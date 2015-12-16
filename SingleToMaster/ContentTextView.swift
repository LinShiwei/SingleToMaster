//
//  ContentTextView.swift
//  SingleToMaster
//
//  Created by Linsw on 15/12/12.
//  Copyright © 2015年 Linsw. All rights reserved.
//

import UIKit

class ContentTextView: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
//    override init(frame: CGRect, textContainer: NSTextContainer?) {
//        super.init(frame: frame, textContainer: textContainer)
//        let tempContentString=self.text
//        self.text = tempContentString.stringByReplacingOccurrencesOfString("\\n|", withString: "\n")
//    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("contentInit")
        
//        以下这两行是使storyboard中textview内预先输入内容里的\n生效，因为在textview中预先输入的\n在存储是会默认存为\\n，所以应该人工将存储文本中的\\n替换为\n
        let tempContentString=self.text
        self.text = tempContentString.stringByReplacingOccurrencesOfString("\\n", withString: "\n")
    }

}
