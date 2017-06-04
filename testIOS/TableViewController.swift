//
//  ViewController.swift
//  testStorytelbridge
//
//  Created by Nikolay Sozinov on 30/05/2017.
//  Copyright © 2017 Nikolay Sozinov. All rights reserved.
//

/*
 
 *** - - - Attention!!! - - - ***
 
 I do not include CocoaPods PodFiles in  this project but I added  and use some HELP files from there ! :)
 
 It's: SwiftyJSON   and  Reachability
 
 */

import UIKit

class TableViewController: UITableViewController {
    
    let urlApi = "http://api.storytelbridge.com/consumables/list/1?page="
    var numPage = 1
    
    var loadMoreStatus = false
    var indicatorFooter:UIActivityIndicatorView?
    
    let reachability = Reachability()!
    
    var titleCell: [ModelTitleCell] = []
    var modelsCell: [ModelCell] = []
    
    @IBOutlet weak var tableview: UITableView!

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        indicatorFooter = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 44))
        indicatorFooter?.color = UIColor.black
        self.tableview.tableFooterView = indicatorFooter
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                     self.getModelData()
                } else {
                    print("Reachable via Cellular")
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

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y + scrollView.frame.size.height  == scrollView.contentSize.height {
            self.refreshTableVeiwList()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTableVeiwList(){
        indicatorFooter?.startAnimating()
        numPage += 1
        getModelData()
    }



    func getModelData(){
    
     let urlRequest = URLRequest(url: URL(string: urlApi + "\(numPage)")!)
        
   
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.titleCell = [ModelTitleCell]()
            do {
                 let json = try! JSON(data: data!)
                
                for (keyJson, valueJson) in json {
                    
                    switch (keyJson){
                    case "metadata" :
                        let myModel = ModelTitleCell()
                        myModel.title = valueJson["title"].stringValue
                        myModel.imageUrl = valueJson["cover"]["url"].stringValue
                        self.titleCell.append(myModel)
                        
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
                                    self.modelsCell.append(modelCell)
                                    
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
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var withIdentifier = "ListTitleCell"
        
        if indexPath.row > 0 {
            withIdentifier = "ListBooksCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: withIdentifier, for: indexPath)
        
        if let firstCell = cell as? ListTitleTableViewCell {
            firstCell.imageTitleView.downloadImage(from: titleCell[indexPath.row].imageUrl!)
            firstCell.listTitle.text = titleCell[indexPath.row].title
            
        }
        
        if let nextCell = cell as? ListBooksTableViewCell {
            
            nextCell.titleBookLabel.text = modelsCell[indexPath.row].title
            nextCell.imageBookView.downloadImage(from: modelsCell[indexPath.row].imageUrl!)
            
            if modelsCell[indexPath.row].author?.count != nil {
                nextCell.textAutorBookLabel.text = "by: " + (modelsCell[indexPath.row].author?.joined(separator: ", "))!
            }
            if modelsCell[indexPath.row].narrator?.count != nil {
                nextCell.textNarratorBookLabel.text = "With: " + (modelsCell[indexPath.row].narrator?.joined(separator: ", "))!
            }
        }
        

        
        return cell
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modelsCell.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200.0
        }
        return 100.0//Choose your custom row height
    }
    
    func errorWebData(){
        //TODO: will need lokalazing text!
        let alert = UIAlertController(title: "Attention!", message: "No Internet, no data is downloaded!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
}

extension UIImageView {
    
    func downloadImage(from url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
