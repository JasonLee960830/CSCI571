//
//  ArtistViewController.swift
//  yunze_hw9
//
//  Created by  jasonlee on 2018/11/25.
//  Copyright © 2018 yunze li. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
class ArtistViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let myGroup = DispatchGroup()
    var items = ["1","2","3","4","5"]
    @IBOutlet weak var checkAtlabel1: UILabel!
    @IBOutlet weak var popularitylabel1: UILabel!
    @IBOutlet weak var followerslabel1: UILabel!
    @IBOutlet weak var namelabel1: UILabel!
    @IBOutlet weak var checkAtlabel: UILabel!
    @IBOutlet weak var popularitylabel: UILabel!
    @IBOutlet weak var followerslabel: UILabel!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var artist1InfoView: UIView!
    @IBOutlet weak var artist2InfoView: UIView!
    @IBOutlet weak var artist2ImageCollectionView: UICollectionView!
    var team1 : String = ""
    var team2 : String = ""
    var image1 : JSON?
    var info1 : JSON?
    var info2 : JSON?
    var image2 : JSON?
    @IBOutlet weak var artist1Name: UILabel!
    @IBOutlet weak var artist1name: UILabel!
    @IBOutlet weak var follower1: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var checkAt: UIButton!
    @IBOutlet weak var artistName2: UILabel!
    @IBOutlet weak var artistname2: UILabel!
    @IBOutlet weak var follower2: UILabel!
    @IBOutlet weak var popularity2: UILabel!
    @IBOutlet weak var checkAt2: UIButton!
    @IBOutlet weak var namelabel2: UILabel!
    @IBOutlet weak var followerlabel2: UILabel!
    @IBOutlet weak var popularitylabel2: UILabel!
    @IBOutlet weak var checkAtlabel2: UILabel!
    @IBAction func checkAtPressed2(_ sender: Any) {
        UIApplication.shared.open(URL(string: info2?["checkAt"].rawString() ?? "")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func checkAtPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: info1?["checkAt"].rawString() ?? "")!, options: [:], completionHandler: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        artist2ImageCollectionView.dataSource = self
        image1 = InfoViewController.image1
        info1 = InfoViewController.info1
        image2 = InfoViewController.image2
        info2 = InfoViewController.info2
        artist1Name.text = InfoViewController.team1
        artist1name.text = info1?["name"].rawString()
        follower1.text = info1?["followers"].rawString()
        popularity.text = info1?["popularity"].rawString()
        artistName2.text = InfoViewController.team2
        artistname2.text = info2?["name"].rawString()
        follower2.text = info2?["followers"].rawString()
        popularity2.text = info2?["popularity"].rawString()
        if(info1?["name"].rawString()=="null"){
            namelabel.isHidden = false
            namelabel1.isHidden = true
            followerslabel1.isHidden = true
            popularitylabel1.isHidden = true
            checkAtlabel1.isHidden = true
            
            artist1name.isHidden = true
            follower1.isHidden = true
            popularity.isHidden = true
            checkAt.isHidden = true
        }
        else{
            namelabel.isHidden = true
            artist1InfoView.isHidden = false
            namelabel1.isHidden = false
            followerslabel1.isHidden = false
            popularitylabel1.isHidden = false
            checkAtlabel1.isHidden = false
            artist1name.isHidden = false
            follower1.isHidden = false
            popularity.isHidden = false
            checkAt.isHidden = false
        }
        if(InfoViewController.team2 == ""){
            
            artist2InfoView.isHidden = true
            artist2ImageCollectionView.isHidden = true
            namelabel.isHidden = true
            followerslabel.isHidden = true
            popularitylabel.isHidden = true
            checkAtlabel.isHidden = true
        }
        else{
            artist2InfoView.isHidden = false
             artist2ImageCollectionView.isHidden = false
            namelabel.isHidden = false
            followerslabel.isHidden = false
            popularitylabel.isHidden = false
            checkAtlabel.isHidden = false
        }
        if(info2?["name"].rawString()=="null"){
            artistname2.isHidden = true
            follower2.isHidden = true
            popularity2.isHidden = true
            checkAt2.isHidden = true
            namelabel2.isHidden = true
            followerlabel2.isHidden = true
            popularitylabel2.isHidden = true
            checkAtlabel2.isHidden = true
        }
        else{
            artistname2.isHidden = false
            follower2.isHidden = false
            popularity2.isHidden = false
            checkAt2.isHidden = false
            namelabel2.isHidden = false
            followerlabel2.isHidden = false
            popularitylabel2.isHidden = false
            checkAtlabel2.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var returnValue = image1?.count;
        if(collectionView == artist2ImageCollectionView){
            returnValue = image2?.count
        }
        return returnValue ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView==artist2ImageCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ArtistImageCollectionViewCell
            //        cell.backgroundColor = UIColor.black
            let imageUrl = URL(string: (image2?[indexPath.item]["link"].rawString())!)!
            //        image1?[0]["link"].rawString() ?? ""
            //get data flow from network
            let imageData = NSData(contentsOf: imageUrl as URL)
            //initialize image through data flow
            let Image = UIImage(data: imageData! as Data)
            var imageV = UIImageView()
            imageV = cell.viewWithTag(1) as! UIImageView
            imageV.image = Image
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ArtistImageCollectionViewCell
    //        cell.backgroundColor = UIColor.black
            let imageUrl = URL(string: (image1?[indexPath.item]["link"].rawString())!)!
    //        image1?[0]["link"].rawString() ?? ""
            //get data flow from network
            let imageData = NSData(contentsOf: imageUrl as URL)
    //        let imageData = try! Data(contentsOf: imageUrl!)
            //initialize image through data flow
            let Image = UIImage(data: imageData! as Data)
    //        let Image = UIImage(data: imageData)
            var imageV = UIImageView()
            imageV = cell.viewWithTag(1) as! UIImageView
            imageV.image = Image
            return cell
        }
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
