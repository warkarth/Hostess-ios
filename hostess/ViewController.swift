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
import SwiftEntryKit
import PassKit

struct Place : Codable{
    let id: Int?
    let name: String?
    let street: String?
    let description: String?
    let detail: String?
}

var places = [Place]()
var urlpasswallet: String!
var lugarid = 0

class ViewController: UIViewController {
    
    fileprivate var card: Card!
    
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    
    fileprivate var contentView: UILabel!
    
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var favoriteButton: IconButton!
    
    
    fileprivate var imageView : UIImageView!
    
    fileprivate var timerLabel: UILabel!
    fileprivate var timerdescLabel: UILabel!
    
    var cardHeight: CGFloat = 0.0
    
    let colorTop =  UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 113.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 255.0/255.0, green: 95.0/255.0, blue: 109.0/255.0, alpha: 1.0).cgColor
    
    let gradientLayer = CAGradientLayer()
    
    var countdownTimer: Timer!
    var totalTime = 0
    
    var robotGif: UIImage!
    var imageGifView: UIImageView!
    
    var squareColor: UIView!
    
    //let API_URL = "https://www.simplifiedcoding.net/demos/marvel/"
    let API_URL = "http://hostess.alejandrozepeda.mx/api/v1/places"

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
    var passButton: UIButton!
    
    let passImage = UIImage(named: "pass")

    
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
        myLabel.text = "¿Dónde quieres comer hoy?"
        myLabel.textColor = Color.darkText.primary
        myLabel.font = RobotoFont.bold(with: 18)
        view.addSubview(myLabel)
        
        //Status label
        lugarLbl = UILabel(frame: CGRect(center: CGPoint(x: 150, y: 130), size: CGSize(width: 250, height: 200)))
        lugarLbl.text = "Toma un turno"
        lugarLbl.textColor = Color.darkText.secondary
        lugarLbl.font = RobotoFont.regular(with: 14)
        view.addSubview(lugarLbl)
        
        //Color del status
        squareColor = UIView(frame: CGRect(x: 170, y: 130, width: 30, height: 30))
        squareColor.backgroundColor = Color.grey.lighten3
        squareColor.clipsToBounds = true
        squareColor.layer.cornerRadius = squareColor.frame.size.width/2
        //view.addSubview(squareColor)
        
        //Etiqueta de aprox
        timerdescLabel = UILabel(frame: CGRect(center: CGPoint(x: 150, y: 150), size: CGSize(width: 250, height: 200)))
        timerdescLabel.textColor = Color.darkText.secondary
        timerdescLabel.font = RobotoFont.regular(with: 12)
        timerdescLabel.text = "Tiempo aprox. "
        
        //Timer for show the remainning time
        timerLabel = UILabel(frame: CGRect(center: CGPoint(x: 230, y: 150), size: CGSize(width: 250, height: 200)))
        timerLabel.textColor = Color.darkText.secondary
        timerLabel.font = RobotoFont.regular(with: 12)
        //view.addSubview(timerLabel)
        
        //Assistant image
        imageView  = UIImageView(frame: CGRect(x: 265, y: 70, width: 90, height: 90));
        imageView.image = UIImage(named: "rob2")
        imageView.backgroundColor = Color.grey.lighten2
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        view.addSubview(imageView)
        
        //Apple wallet pass image
        passButton = UIButton(type: UIButtonType.custom) as UIButton
        passButton = UIButton(type: UIButtonType.system) as UIButton
        passButton.frame = CGRect(x: 170,y: 80,width: 80,height: 30)
        passButton .setBackgroundImage(passImage, for: [])
        //passButton.addTarget(self, action: "Action:", forControlEvents:UIControlEvents.TouchUpInside)
        

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
                self.prepareDateLabel(detail: place.detail!)
                self.prepareFavoriteButton(id: place.id!)
                self.prepareMoreButton()
                self.prepareToolbar(title: place.name!,detail: place.street!)
                self.prepareContentView(bio: place.description!)
                self.prepareBottomBar()
                self.prepareCard(space: CGFloat( 300 - i))
                i = i + self.cardHeight + 225.0
            }
            
        }
        //startTimer() //Timer for wait your turn
        
        
        view.addSubview(scrollView)
        setNavigationBar()
        
        
    }
    
    func pusherConnect(chanelPost:String){
        print("Conectando")
        let channel = self.pusher.subscribe(chanelPost)
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    self.lugarLbl.text = message;
                    switch(message){
                        case "Te hemos formado":
                            print("Confirmado")
                            /*self.squareColor.backgroundColor = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)*/
                            self.imageView.backgroundColor = Color.green.lighten3
                            self.view.addSubview(self.timerdescLabel)
                            self.view.addSubview(self.timerLabel)
                            self.startTimer() //Timer for wait your turn
                        case "Es tu turno":
                            print("Atendido")
                            /*self.squareColor.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)*/
                            self.imageView.backgroundColor = Color.blue.lighten3
                        case "Te estamos esperando":
                            print("No show")
                            self.imageView.backgroundColor = Color.orange.lighten3
                            self.updateTime()
                            self.startTimer()
                        default:
                            self.squareColor.backgroundColor = Color.grey.lighten3
                    }
                    print(message)
                }
            }
        })
        self.pusher.connect()
    }
}

func loadData(completion: @escaping (Array<Place>) -> Void){
    //defining the API URL
    let API_URL = "http://hostess.alejandrozepeda.mx/api/v1/places"
    
    Alamofire.request(API_URL, method: .get).responseJSON { response in
        let json = response.data
        
        do{
            //created the json decoder
            let decoder = JSONDecoder()
            
            //using the array to put values
            places = try decoder.decode([Place].self, from: json!)
            
            
            for place in places{
                print(place.name!)
            }
            
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

    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        timerLabel.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    fileprivate func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    fileprivate func prepareDateLabel(detail: String) {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.grey.lighten3
        //dateLabel.text = dateFormatter.string(from: Date.distantFuture)
        let mins = String(detail)
        dateLabel.text = "\(mins) mins. aprox"
    }
    
    fileprivate func prepareFavoriteButton(id: Int?) {
        favoriteButton = IconButton(image: Icon.add, tintColor: Color.lightText.primary)
        favoriteButton.tag = id!
        favoriteButton.addTarget(self, action: #selector(sayAction(_:)), for: .touchUpInside)
    }
    
    @objc private func sayAction(_ sender: UIButton?) {
        var attributes = EKAttributes.topFloat
        attributes.displayDuration = .infinity
        attributes.entryBackground = .gradient(gradient: .init(colors: [UIColor(red: 0.0/255.0, green: 92.0/255.0, blue: 151.0/255.0, alpha: 1.0), UIColor(red: 54.0/255.0, green: 55.0/255.0, blue: 149.0/255.0, alpha: 1.0)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        let minEdge = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: minEdge), height: .intrinsic)
        attributes.screenInteraction = .dismiss
        attributes.screenBackground = .color(color: UIColor.black.withAlphaComponent(0.8))
        let title = EKProperty.LabelContent(text: "PIDE TU TURNO",style: .init(font: RobotoFont.bold(with: 16), color: Color.lightText.primary))
        
        
        let titleField1 = EKProperty.LabelContent(text: "Nombre",style: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary))
        
        let field1 = EKProperty.TextFieldContent(placeholder: titleField1, textStyle: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary), leadingImage: UIImage(named: "nombre"))
        
        let titleField2 = EKProperty.LabelContent(text: "Número de personas",style: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary))
        
        let field2 = EKProperty.TextFieldContent(keyboardType: UIKeyboardType.numberPad, placeholder: titleField2, textStyle: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary), leadingImage: UIImage(named: "personas"))
        
        let titleField3 = EKProperty.LabelContent(text: "Teléfono",style: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary))
        
        let field3 = EKProperty.TextFieldContent(keyboardType: UIKeyboardType.phonePad, placeholder: titleField3, textStyle: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary), leadingImage: UIImage(named: "telefono"))
        
        let titleField4 = EKProperty.LabelContent(text: "Detalle",style: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary))
        
        let field4 = EKProperty.TextFieldContent(placeholder: titleField4, textStyle: .init(font: RobotoFont.regular(with: 12), color: Color.lightText.secondary), leadingImage: UIImage(named: "detalle"))
        
        let button = EKProperty.ButtonContent(label: .init(text: "TOMAR TURNO", style: .init(font: RobotoFont.bold(with: 12), color: .black)),backgroundColor: Color.grey.lighten4, highlightedBackgroundColor: .yellow) {
            
            let lugarid : Int = (sender?.tag)!
            print(lugarid)
            let urlString = "http://hostess.alejandrozepeda.mx/api/v1/\(lugarid)/tickets"
            
            Alamofire.request(urlString, method: .post, parameters: ["name": field1.output, "seats": field2.output, "phone": field3.output, "detail": field4.output],encoding: JSONEncoding.default, headers: nil).responseJSON {
                    response in switch response.result {
                        case .success(let responseJSON):
                            
                            let response = responseJSON as! NSDictionary
                            let pusherChannel = response.object(forKey: "pusher_channel")
                            let urlPass = response.object(forKey: "url_wallet_pass")
                            urlpasswallet = urlPass as! String
                            self.pusherConnect(chanelPost: pusherChannel as! String)
                            
                            //"http://hostess.alejandrozepeda.mx/pkpass"
                            if let url = URL(string: urlPass as! String ) {
                                UIApplication.shared.open(url, options: [:])
                            }
                            
                            self.passButton.addTarget(self, action: #selector(self.loadPass(_:)), for:UIControlEvents.touchUpInside)
                            
                            self.myLabel.text = "Hostess dice: "
                            self.lugarLbl.text = "Buscando tu mesa..."
                            self.view.addSubview(self.passButton)
                            
                            
                            self.totalTime =  response.object(forKey: "wait_time") as! Int
                            
                            break
                        case .failure(let error):
                            print("Pedir turno fallido")
                            print(error)
                    }
            }
            
            SwiftEntryKit.dismiss()
        }
        let contentView = EKFormMessageView(with: title, textFieldsContent: [field1,field2,field3,field4], buttonContent: button)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    @objc private func loadPass(_ sender: UIButton?) {
        print("Button clicked")
        if let url = URL(string: urlpasswallet ) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: UIColor(red: 252.0/255.0, green: 84.0/255.0, blue: 87.0/255.0, alpha: 1))
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
        
        self.cardHeight = card.bounds.height
        
        scrollView.layout(card).vertically(top: -1500, bottom: space)
        scrollView.layout(card).horizontally(left: 20, right: 20).center(offsetX: 0, offsetY: -235)
    }
}


