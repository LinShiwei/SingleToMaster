//
//  ViewController.swift
//  SingleToMaster
//
//  Created by Linsw on 15/12/10.
//  Copyright © 2015年 Linsw. All rights reserved.
//

import UIKit
import CoreData
class DetailViewController: UIViewController {
    
    @IBOutlet weak var contentTextView: UITextView!

//    用来保存初始的textView的大小
    var defaultContentTextViewFrame:CGRect!
//    用来保存indexpath.row
    var thisArticle:NSManagedObject?
    
    var contentTemp:String?{
        didSet{
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface
        if let detail = self.contentTemp {
            if let content = self.contentTextView {
                content.text = detail
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        defaultContentTextViewFrame=self.contentTextView.frame

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        defaultContentTextViewFrame=self.contentTextView.frame
        
    }
    override func viewWillAppear(animated:Bool) {
        //        注册消息，关联消息响应函数
        let NotificationCenter=NSNotificationCenter.defaultCenter()
        NotificationCenter.addObserver(self,selector:"keyboardDidShow:",name:UIKeyboardDidShowNotification, object:nil)
        NotificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NotificationCenter.addObserver(self, selector: "textViewDidChange:", name: UITextViewTextDidChangeNotification, object: nil)
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(animated:Bool){
        //解除注册的消息
        let NotificationCenter=NSNotificationCenter.defaultCenter()
        NotificationCenter.removeObserver(self,name:UIKeyboardDidShowNotification, object:nil)
        NotificationCenter.removeObserver(self,name:UIKeyboardWillHideNotification,object:nil)
        NotificationCenter.removeObserver(self,name: UITextViewTextDidChangeNotification,object: nil)
        
        super.viewWillDisappear(animated)
        
        
    }
    
    //MARK: keyboard
    func keyboardDidShow(notif:NSNotification)->Void{
        NSLog("jianpandakai");
              //获取键盘大小，用来调整textView的大小
//        获取键盘大小，方法一
        var keyboardRect = notif.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
//        获取键盘大小、方法二，等效于方法一
//        let userInfo=notif.userInfo!
//        let aValue=userInfo[UIKeyboardFrameEndUserInfoKey]
//        var keyboardRect=aValue!.CGRectValue
        
//        这里将keyboardRect转化到contentTextView坐标系里
//        以下这一行如果写成 keyboardRect=contentTextView.convertRect(keyboardRect, fromView: nil)，无法达到预期效果，这里的self.view是DetailView

        keyboardRect=self.view.convertRect(keyboardRect, fromView: nil)
//        取contentTextView和Keyboard框架的交集
        let intersect=CGRectIntersection(contentTextView.frame, keyboardRect)
//        调整textView的大小（高度），由于左上角起始点坐标不变，相当于调整textView底部的位置
////        let temp=7.7
        contentTextView.frame.size.height-=intersect.size.height

       
//        NSLog("intersect%f",intersect.size.height)
/*  方法二
        var adjustHeight = contentTextView.frame.origin.y + contentTextView.frame.size.height;
        // 根据相对位置调整一下大小，自己画图比划一下就知道为啥要这样计算。
        // 当然用其他的调整方式也是可以的，比如取UITextView的orgin，origin到键盘origin之间的高度作为UITextView的高度也是可以的。

        adjustHeight -= keyboardRect.origin.y
         NSLog("contentTextView.frame.height%f" ,contentTextView.frame.size.height)
        NSLog("contentTextView.frame.oY%f" ,contentTextView.frame.origin.y)

        NSLog("keyboard.Height%f" ,keyboardRect.size.height)
        NSLog("keyboard.oY%f" ,keyboardRect.origin.y)

        NSLog("adjustHeight%f" ,adjustHeight)

        if (adjustHeight > 0) {
            NSLog("adjustHeight>0")
            var newRect = contentTextView.frame;
            newRect.size.height -= adjustHeight;
            UIView.beginAnimations(nil, context: nil)
            contentTextView.frame = newRect;
            UIView.commitAnimations()
        }
*/
//        最后要更新约束
        self.contentTextView.updateConstraints()
        
        //在键盘打开时，将光标的位置滚动到视野内
        contentTextView.scrollRangeToVisible(contentTextView.selectedRange)
        
    }
    func keyboardWillHide(notif:NSNotification)->Void{
        NSLog("guanbi")
        contentTextView.frame=defaultContentTextViewFrame
        self.contentTextView.updateConstraints()
    }
    //MARK: textView
    func textViewDidChange(notif:NSNotification)->Void{
        NSLog("change")
    //当textView中输入内容的时候，时刻跟踪，保持光标在视野范围内
        UIView.beginAnimations(nil, context: nil)
        contentTextView.scrollRangeToVisible(contentTextView.selectedRange)
        UIView.commitAnimations()
        NSLog("contentTextView.frame.height%f" ,contentTextView.frame.size.height)

//        当内容发生改变时，进行保存
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//
        thisArticle?.setValue(contentTextView.text, forKey: "contentText")
    }

}

