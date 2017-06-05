//
//  ViewController.swift
//  testStorytelbridge
//
//  Created by Nikolay Sozinov on 30/05/2017.
//  Copyright © 2017 Nikolay Sozinov. All rights reserved.
//

/*
 
 *** - - - Attention!!! - - - ***
 
 I do not include CocoaPods PodFiles in  this project but I added  and use some Helpers files from there ! :)
 
 It's: SwiftyJSON   and  Reachability
 
 */

import UIKit

class ReaderWiewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let urlApi = "http://api.storytelbridge.com/consumables/list/1?page="
    var numPage = 1
    var indicatorFooter:UIActivityIndicatorView?
    let reachability = Reachability()!
    var titleCell: ModelTitleCell = ModelTitleCell()
    var xxxCell: [ModelCell] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorFooter = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 44))
        indicatorFooter?.color = UIColor.black
        self.tableview.tableFooterView = indicatorFooter
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachable {
                    print("Reachable via WiFi")
                    self.getModelData()
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
                self.errorWebData()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //get start refresh-download runer
        if scrollView.contentOffset.y + scrollView.frame.size.height  > scrollView.contentSize.height {
            self.refreshTableVeiwList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTableVeiwList(){
        if reachability.isReachable {
            indicatorFooter?.startAnimating()
            numPage += 1
            getModelData()
        }
    }
    
    
    
    func getModelData() {
        
        let urlRequest = URLRequest(url: URL(string: urlApi + "\(numPage)")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                print(error!)
                return
            }
            do {
                let json = try! JSON(data: data!)
                
                for (keyJson, valueJson) in json {
                    
                    switch (keyJson) {
                    case "metadata" :
                        self.titleCell.title = valueJson["title"].stringValue
                        self.titleCell.imageUrl = valueJson["cover"]["url"].stringValue
                        
                    case "consumables":
                        let tableCellData = valueJson
                        for (_ , valueNewJson) in tableCellData {
                            
                            let finalTableCellData = valueNewJson
                            for (keyFinalJson , valueFinalJson) in finalTableCellData {
                                
                                let modelCell = ModelCell()
                                
                                switch (keyFinalJson) {
                                case "metadata" :
                                    modelCell.title = valueFinalJson["title"].stringValue
                                    modelCell.imageUrl = valueFinalJson["cover"]["url"].stringValue
                                    
                                    modelCell.author = []
                                    for (_ , authors) in valueFinalJson["authors"] {
                                        
                                        let autor = authors["name"].stringValue
                                        modelCell.author?.append(autor)
                                    }
                                    modelCell.narrator = []
                                    for (_ , narrators) in valueFinalJson["narrators"] {
                                        
                                        let narrator = narrators["name"].stringValue
                                        modelCell.narrator?.append(narrator)
                                    }
                                    self.xxxCell.append(modelCell)
                                    
                                default:
                                    break
                                }
                            }
                        }
                    default:
                        break
                        
                    }
                }
                
                DispatchQueue.main.async {
                    if (self.indicatorFooter?.isAnimating)! {
                        self.indicatorFooter?.stopAnimating()
                    }
                    self.tableview.reloadData()
                }
            }
        }
        
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let withIdentifier =  indexPath.row > 0 ? "ListBooksCell" : "ListTitleCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: withIdentifier, for: indexPath)
        
        if let firstCell = cell as? ListTitleTableViewCell {
            firstCell.imageTitleView.downloadImage(from: (titleCell.imageUrl)!)
            firstCell.listTitle.text = titleCell.title
            
        }
        
        if let nextCell = cell as? ListBooksTableViewCell {
            
            nextCell.titleBookLabel.text = xxxCell[indexPath.row - 1].title
            nextCell.imageBookView.downloadImage(from: xxxCell[indexPath.row - 1].imageUrl!)
            
            if xxxCell[indexPath.row - 1].author?.count != nil {
                nextCell.textAutorBookLabel.text = "by: " + (xxxCell[indexPath.row - 1].author?.joined(separator: ", "))!
            }
            if xxxCell[indexPath.row - 1].narrator?.count != nil {
                nextCell.textNarratorBookLabel.text = "With: " + (xxxCell[indexPath.row - 1].narrator?.joined(separator: ", "))!
            }
        }
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.xxxCell.count > 0 ? self.xxxCell.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  indexPath.row == 0 ? 200.0 : 100.0  //Choose your custom row height
    }
    
    func errorWebData() {
        //TODO: will need lokalazing text!
        let alert = UIAlertController(title: "Attention!", message: "No Internet, no data is downloaded!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

