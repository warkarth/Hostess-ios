//
//  ViewController.swift
//  hostess
//
//  Created by Nimblr on 20/07/18.
//  Copyright © 2018 ricardo. All rights reserved.
//

import UIKit
import Alamofire
import Material
import PusherSwift

struct Hero : Codable{
    let name:String?
    let realname: String?
    let team: String?
    let firstappearance: String?
    let createdby: String?
    let publisher: String?
    let imageurl: String?
    let bio: String?
}

struct Place : Codable{
    let name: String?
    let street: String?
    let description: String?
}

var heroes = [Hero]()
var places = [Place]()

class ViewController: UIViewController {
    
    fileprivate var card: Card!
    
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    
    fileprivate var contentView: UILabel!
    
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var favoriteButton: IconButton!
    
    
    let colorTop =  UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 113.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 255.0/255.0, green: 95.0/255.0, blue: 109.0/255.0, alpha: 1.0).cgColor
    
    let gradientLayer = CAGradientLayer()
    
    //let API_URL = "https://www.simplifiedcoding.net/demos/marvel/"
    let API_URL = "ec2-18-221-152-120.us-east-2.compute.amazonaws.com/api/v1/places"

    let options = PusherClientOptions(
        host: .cluster("us2")
    )
    let pusher = Pusher(
        key: "22d617d51915d0939b45",
        options: PusherClientOptions(
            host: .cluster("us2")
        )
    )
    
    var scrollView: UIScrollView!
    var myView = UIView()
    var myLabel: UILabel!
    var lugarLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gradiente
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        //view.layer.addSublayer(gradientLayer)
        
        
        view.backgroundColor = Color.grey.lighten3
        
        //Tamaños de pantalla
        let screensize: CGRect = view.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        
        /*myView = UIView(frame: CGRect(x: 5, y: 50, width: screenWidth - 10 , height: 120))
        myView.backgroundColor = .blue
        view.addSubview(myView)*/
        
        //Etiquetas de inicio
        myLabel = UILabel(frame: CGRect(center: CGPoint(x: 150, y: 100), size: CGSize(width: 250, height: 200)))
        myLabel.text = "Dónde quieres turnear?"
        myLabel.textColor = Color.darkText.primary
        myLabel.font = RobotoFont.bold(with: 20)
        view.addSubview(myLabel)
        
        lugarLbl = UILabel(frame: CGRect(center: CGPoint(x: 150, y: 130), size: CGSize(width: 250, height: 200)))
        lugarLbl.text = "Escoge un lugar"
        lugarLbl.textColor = Color.darkText.secondary
        lugarLbl.font = RobotoFont.regular(with: 14)
        view.addSubview(lugarLbl)
        
        let channel = pusher.subscribe("my-channel")
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    self.myLabel.text = message;
                    print(message)
                }
            }
        })
        
        pusher.connect()
        
        //ScrollView
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 175, width: screenWidth, height: screenHeight - 100))
        scrollView.backgroundColor = Color.grey.lighten4
        //scrollView.layer.addSublayer(gradientLayer)
        
        //Carga las cartas de los lugares provenientes del request
        loadData(){(places) in
            var i : CGFloat = 0.0
            //for hero in heroes {
            for place in places {
                self.prepareDateFormatter()
                self.prepareDateLabel()
                self.prepareFavoriteButton()
                self.prepareMoreButton()
                //self.prepareToolbar(title: hero.name!,detail: hero.realname!)
                self.prepareToolbar(title: place.name!,detail: place.street!)
                self.prepareContentView(bio: place.description!)
                self.prepareBottomBar()
                self.prepareCard(space: CGFloat( 300 - i))
                i = i + self.card.bounds.height + 185.0
            }
            
        }
        
        view.addSubview(scrollView)
        setNavigationBar()
    }
}

func loadData(completion: @escaping (Array<Place>) -> Void){
    //defining the API URL
    //let API_URL = "https://www.simplifiedcoding.net/demos/marvel/"
    let API_URL = "ec2-18-221-152-120.us-east-2.compute.amazonaws.com/api/v1/places"
    
    Alamofire.request(API_URL, method: .get).responseJSON { response in
        let json = response.data
        
        do{
            //created the json decoder
            let decoder = JSONDecoder()
            
            //using the array to put values
            //heroes = try decoder.decode([Hero].self, from: json!)
            places = try decoder.decode([Place].self, from: json!)
            
            //printing all the hero names
            /*for hero in heroes{
                print(hero.name!)
            }*/
            for place in places{
                print(place.name!)
            }
            
            //let response = heroes + heroes
            let response = places
            completion(response)
        }catch let err{
            print(err)
            print("YA VALIO MADRE EL REQUEST")
        }
    }
    
}

extension ViewController {
    
    fileprivate func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 46.0))
        let navItem = UINavigationItem(title: "")
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    @objc func done() { // remove @objc for Swift 3
        
    }
    
    fileprivate func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.grey.lighten3
        dateLabel.text = dateFormatter.string(from: Date.distantFuture)
    }
    
    fileprivate func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.add, tintColor: Color.lightText.primary)
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.lightText.others)
    }
    
    fileprivate func prepareToolbar(title: String, detail: String) {
        toolbar = Toolbar(rightViews: [moreButton])
        
        toolbar.title = title
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.textColor = Color.lightText.primary
        
        toolbar.detail = detail
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.textColor = Color.lightText.secondary
        toolbar.backgroundColor = UIColor(red: 252.0/255.0, green: 84.0/255.0, blue: 87.0/255.0, alpha: 1)
    }
    
    fileprivate func prepareContentView(bio: String) {
        contentView = UILabel()
        contentView.numberOfLines = 0
        contentView.text = bio
        contentView.font = RobotoFont.regular(with: 14)
        contentView.textColor = Color.lightText.secondary
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar()
        
        bottomBar.leftViews = [favoriteButton]
        bottomBar.rightViews = [dateLabel]
        bottomBar.backgroundColor = UIColor(red: 252.0/255.0, green: 84.0/255.0, blue: 87.0/255.0, alpha: 1)
    }
    
    fileprivate func prepareCard(space: CGFloat) {
        card = Card()

        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .square3
        card.toolbarEdgeInsets.bottom = 0
        card.toolbarEdgeInsets.right = 8
        
        card.contentView = contentView
        card.contentViewEdgeInsetsPreset = .wideRectangle3
        
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        card.clipsToBounds = true
        card.layer.cornerRadius = 20
        card.backgroundColor = UIColor(red: 252.0/255.0, green: 84.0/255.0, blue: 87.0/255.0, alpha: 1)
        
        scrollView.layout(card).vertically(top: -1400, bottom: space)
        scrollView.layout(card).horizontally(left: 20, right: 20).center(offsetX: 0, offsetY: -180)
    }
}

