//
//  DataManager.swift
//  Unsplash
//
//  Created by Dimique on 21/01/2021.
//

import UIKit

class GetData: ObservableObject {
    @Published var Images: [[Photo]] = []
    @Published var noresults = false
    
    init() {
        updateData()
    }
    
    func updateData() {
        self.noresults = false
        
        let key = "mlCKA-SD6Vn-wyyLc0gs2_VyWqBrXpCvqVAVR6NGxfA"
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            //JSON decoding
            
            do {
                let json = try JSONDecoder().decode([Photo].self, from: data!)
                
                // Creating a collection
                for i in stride(from: 0, to: json.count, by: 2) {
                    var ArrayData: [Photo] = []
                    
                    for j in i..<i+2 {
                        if j < json.count {
                            ArrayData.append(json[j])
                        }
                    }
                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        .resume()
    }
    
    func searchData(url: String) {

        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            //JSON decoding
            
            do {
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                
                DispatchQueue.main.async {
                    if json.results.isEmpty {
                        self.noresults = true
                    } else {
                        self.noresults = false
                    }
                }
                
                // Creating a collection
                for i in stride(from: 0, to: json.results.count, by: 2) {
                    var ArrayData: [Photo] = []
                    
                    for j in i..<i+2 {
                        if j < json.results.count {
                            ArrayData.append(json.results[j])
                        }
                    }
                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        .resume()
    }
}
