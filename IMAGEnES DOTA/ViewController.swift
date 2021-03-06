//
//  ViewController.swift
//  IMAGEnES DOTA
//
//  Created by MAC01 on 18/12/21.
//

import UIKit

extension UIImageView {
    func downloadedFrom (url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloadeFrom (link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom (url: url, contentMode: mode)
    }
}

//    una simple api de dota en swift
struct Hero: Decodable {
    let localized_name: String
    let img: String
}


class ViewController: UIViewController, UICollectionViewDataSource{

    var heroes = [Hero]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        let url = URL(string: "https://api.opendota.com/api/heroStats")
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error == nil {
                    do {
                        self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                    }catch {
                        print("Parse Error")
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  heroes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.nameLbl.text = heroes[indexPath.row].localized_name.capitalized
        cell.imageView.contentMode = .scaleAspectFill
        
        let defaultLink = "http://api.opendota.com"
        let completeLink = defaultLink + heroes[indexPath.row].img
        
        cell.imageView.downloadeFrom(link: completeLink)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
        return cell
    }
}
