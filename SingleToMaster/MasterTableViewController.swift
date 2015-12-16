//
//  MasterTableViewController.swift
//  SingleToMaster
//
//  Created by Linsw on 15/12/10.
//  Copyright © 2015年 Linsw. All rights reserved.
//

import UIKit
import CoreData

extension NSDate {
    func dayOfWeek() -> String {
        let interval = self.timeIntervalSince1970
        let days = Int(interval / 86400)
        switch((days - 3) % 7){
        case 0:
            return "星期日"
        case 1:
            return "星期一"
        case 2:
            return "星期二"
        case 3:
            return "星期三"
        case 4:
            return "星期四"
        case 5:
            return "星期五"
            
        default:
            return "星期六"
        }
    }
}

class MasterTableViewController: UITableViewController {

    var myArticle = [NSManagedObject]()
    var detailViewController:DetailViewController?=nil
    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem!.title = "编辑"
//        增添“添加”按钮
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewArticle:")
        self.navigationItem.rightBarButtonItem = addButton

        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        从coredata中获取数据
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let fetchRequest = NSFetchRequest(entityName: "MyArticle")
        //3
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            myArticle = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    

    func insertNewArticle(sender: AnyObject){
//        在数据中插入新项
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let entity = NSEntityDescription.entityForName("MyArticle", inManagedObjectContext:managedContext)
        let article = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        //3
        let designDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var designDateString = dateFormatter.stringFromDate(designDate)
        designDateString += " "
        designDateString += designDate.dayOfWeek()
        article.setValue(designDateString, forKey: "designDate")
        article.setValue("defaultContent", forKey: "contentText")

        //4
        do {
//            下面这一步是是修改的结果保存到coredata中，前面几步只是在managedObjectContext中进行修改，还没有真正保存
            try managedContext.save()
            //5
//            myArticle.insert(article, atIndex: 0)
//            
            myArticle.append(article)
        }
        catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
//        在tableview中插入新行
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.tableView.reloadData()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myArticle.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MasterTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MasterTableViewCell
//        let article = myArticle[indexPath.row]
//        将数据库中的数据倒序输出在tableview中，使最新插入的数据，排在tableview的第一行
       let article = myArticle[myArticle.count - 1 - indexPath.row]
        // Configure the cell...
        cell.designDate.text = article.valueForKey("designDate")?.description
        
        
//        将content的前三十个字符设置为contentLabel
        let content = article.valueForKey("contentText") as? String
//        let toIndex:String.CharacterView.Index
//        if content?.endIndex < content?.startIndex.advancedBy(29){
//            toIndex = (content?.endIndex)!
//        }else{
//            toIndex = (content?.startIndex.advancedBy(29))!
// 
//        }
        cell.contentLabel.text = content
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

//            从数据库中删除该项
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(myArticle[myArticle.count - 1 - indexPath.row])
            do {
//                保存删除的结果（使删除生效）
                try managedContext.save()
                
            }
            catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
//            再从数组中移除数据
            myArticle.removeAtIndex(myArticle.count - 1 - indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()

        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
//            self.tableView.reloadData()
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                let article = myArticle[myArticle.count - 1 - indexPath.row]
//              设置detailViewController中的contentTextView的内容
                controller.contentTemp = article.valueForKey("contentText") as? String
//              将article传递到detailViewController中
                controller.thisArticle = article
                self.tableView.reloadData()

            }
        }
    }
    

}
