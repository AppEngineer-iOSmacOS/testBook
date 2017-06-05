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

class ReaderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var numPage = 1
    var indicatorFooter:UIActivityIndicatorView?
    let reachability = Reachability()!
    var titleCellModel: TitleCellModel?
    var listCellModel: [CellModel] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorFooter = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 44))
        indicatorFooter?.color = UIColor.black
        self.tableview.tableFooterView = indicatorFooter
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachable {
                    print(reachability.currentReachabilityStatus)
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
    
    func refreshTableVeiwList() {
        guard reachability.isReachable else {
            return
        }
        indicatorFooter?.startAnimating()
        getModelData()
    }
    
    
    
    func getModelData() {
        
        let urlRequest = URLRequest(url: URL(string: APIConstants.sharedInstance.urlApi + "\(numPage)")!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                print(error!)
                return
            }
            do {
                let json = try! JSON(data: data!)
                self.numPage += 1
                for (keyJson, valueJson) in json {
                    
                    switch (keyJson) {
                    case "metadata" :
                        self.titleCellModel = TitleCellModel()
                        self.titleCellModel?.title = valueJson["title"].stringValue
                        self.titleCellModel?.imageUrl = valueJson["cover"]["url"].stringValue
                        
                    case "consumables":
                        let tableCellData = valueJson
                        for (_ , valueNewJson) in tableCellData {
                            
                            let finalTableCellData = valueNewJson
                            for (keyFinalJson , valueFinalJson) in finalTableCellData {
                                
                                let modelCell = CellModel()
                                
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
                                    self.listCellModel.append(modelCell)
                                    
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
            
            if (titleCellModel?.imageUrl) != nil {
                firstCell.imageTitleView.downloadImage(from: (titleCellModel?.imageUrl)!)
            }
            firstCell.listTitle.text = titleCellModel?.title ?? "No data, please refresh"
            
        }
        
        if let nextCell = cell as? ListBooksTableViewCell {
            
            nextCell.titleBookLabel.text = listCellModel[indexPath.row - 1].title ?? "No data, please refresh"
            nextCell.imageBookView.downloadImage(from: listCellModel[indexPath.row - 1].imageUrl ?? "NoImage")
            
            if listCellModel[indexPath.row - 1].author?.count != nil {
                nextCell.textAutorBookLabel.text = "by: " + (listCellModel[indexPath.row - 1].author?.joined(separator: ", "))!
            }
            if listCellModel[indexPath.row - 1].narrator?.count != nil {
                nextCell.textNarratorBookLabel.text = "With: " + (listCellModel[indexPath.row - 1].narrator?.joined(separator: ", "))!
            }
        }
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // + 1 -> Because we have a Title Cell in first cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.listCellModel.count + 1
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

