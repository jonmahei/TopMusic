//
//  DetailsVC.swift
//  TopMusic
//
//  Created by Jon-Martin Heiberg on 29/10/2019.
//  Copyright © 2019 JMHeiberg. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var trackTable: UITableView!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumYear: UILabel!
    

    
    var tracks: [Track] = []
    var albumId: String = ""
    let cellIdentifier = "albumTrackCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebAPI.getAlbum(albumId: albumId, completion: { response in
            if let album = response {
                self.updateView(with: album[0])
            }
        })

        WebAPI.getTracks(albumId: albumId, completion: { response in
            if let tracks = response {
                self.tracks = tracks
                self.trackTable.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DetailsTableViewCell
        
        cell.trackName?.text = "\(indexPath.row + 1). \(tracks[indexPath.row].strName)"
        cell.trackDuration.text = Utils.convertSeconds(milliseconds: tracks[indexPath.row].intDuration)
        
        return cell
    }
    
    func updateView(with album: Album) {
        self.albumTitle.text = album.strName
        self.artistName.text = album.strArtist
        self.albumYear.text = album.intYearReleased
        if let strUrl = album.strThumb {
            let url = URL(string: strUrl)
            if let unwrappedUrl = url {
                albumImage.load(url: unwrappedUrl)
                return
            }
        }
        albumImage.image = UIImage(named: "Mockup_CD")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Add to favourite?", message: "Do you want to add '\(tracks[indexPath.row].strName)' to favourites?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {_ in
            self.addToFavourite(index: indexPath.row)
        }))
        self.present(alert, animated: true)
    }
    
    func addToFavourite(index: Int) {
        
        let selectedTrack = tracks[index]
        
        let moc =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
        
         
        let entity = NSEntityDescription.entity(forEntityName: "FavouriteTrack", in: moc)
        let newFavouriteTrack = FavouriteTrack(entity: entity!, insertInto: moc)
        
        newFavouriteTrack.setValue(selectedTrack.idAlbum, forKey: "idAlbum")
        newFavouriteTrack.setValue(selectedTrack.idTrack, forKey: "idTrack")
        newFavouriteTrack.setValue(selectedTrack.intDuration, forKey: "intDuration")
        newFavouriteTrack.setValue(selectedTrack.strAlbum, forKey: "strAlbum")
        newFavouriteTrack.setValue(selectedTrack.strArtist, forKey: "strArtist")
        newFavouriteTrack.setValue(selectedTrack.strName, forKey: "strName")
        newFavouriteTrack.setValue(selectedTrack.strThumb, forKey: "strThumb")
        
        do {
            try moc.save()
            print("saved")
        } catch {
            print("failed saving")
        }
        
        
          // read from core data
        /*
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteTrack")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let newTrack: Track = Track(
                    artist: (data.value(forKey: "strArtist") as? String)!,
                    trackId: (data.value(forKey: "idTrack") as? String)!,
                    name: (data.value(forKey: "strName") as? String)!,
                    albumId: (data.value(forKey: "idAlbum") as? String)!,
                    album: (data.value(forKey: "strAlbum") as? String)!,
                    duration: (data.value(forKey: "intDuration") as? String)!,
                    thumb: data.value(forKey: "strArtist") as? String
                )
                
                print(newTrack)
            }
        } catch {
            print("failed")
        }
        */
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}