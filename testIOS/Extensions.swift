//
//  Extensions.swift
//  testIOS
//
//  Created by admin on 05/06/2017.
//  Copyright © 2017 Nikolay Sozinov. All rights reserved.
//

import Foundation
import UIKit


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
