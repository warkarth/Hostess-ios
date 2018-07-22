//
//  CardTableViewCell.swift
//  hostess
//
//  Created by Nimblr on 20/07/18.
//  Copyright © 2018 ricardo. All rights reserved.
//

import UIKit
import Material
import Motion
import Graph

class CardTableViewCell: TableViewCell {
    
    private var spacing: CGFloat = 10
    
    /// A boolean that indicates whether the cell is the last cell.
    public var isLast = false
    
    public lazy var card: PresenterCard = PresenterCard()
    
    /// Toolbar views.
    private var toolbar: Toolbar!
    private var profileImage: UIImageView!
    private var moreButton: IconButton!
    
    /// Presenter area.
    private var presenterImageView: UIImageView!
    
    /// Content area.
    private var contentLabel: UILabel!
    
    /// Bottom Bar views.
    private var bottomBar: Bar!
    private var dateFormatter: DateFormatter!
    private var dateLabel: UILabel!
    private var favoriteButton: IconButton!
    private var shareButton: IconButton!
    
    public var data: Entity? {
        didSet {
            layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let d = data else {
            return
        }
        
        toolbar.title = d["title"] as? String
        toolbar.detail = d["detail"] as? String
        
        contentLabel.text = d["content"] as? String
        
        dateLabel.text = dateFormatter.string(from: d.createdDate)
        
        card.frame.origin.x = 10
        card.frame.origin.y = 10
        card.frame.size.width = bounds.width - 20
        
        card.backgroundColor = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 0.8)
        
        frame.size.height = card.bounds.height
    }
    
    open override func prepare() {
        super.prepare()
        
        layer.rasterizationScale = Screen.scale
        layer.shouldRasterize = true
        
        pulseAnimation = .none
        backgroundColor = nil
        
        prepareDateFormatter()
        prepareDateLabel()
        prepareProfileImage()
        prepareMoreButton()
        prepareToolbar()
        prepareFavoriteButton()
        prepareShareButton()
        prepareContentLabel()
        prepareBottomBar()
        preparePresenterCard()
    }
    
    private func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
        
    }
    
    private func prepareProfileImage() {
        profileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        profileImage.shapePreset = .circle
    }
    
    private func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.blueGrey.base)
    }
    
    private func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.red.base)
    }
    
    private func prepareShareButton() {
        shareButton = IconButton(image: Icon.cm.share, tintColor: Color.blueGrey.base)
    }
    
    private func prepareToolbar() {
        toolbar = Toolbar()
        
        toolbar.heightPreset = .xlarge
        
        toolbar.titleLabel.textAlignment = .left
        toolbar.detailLabel.textAlignment = .left
        
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.font = RobotoFont.bold(with: 22)
        
        toolbar.leftViews = [profileImage]
        toolbar.rightViews = [moreButton]
        
        toolbar.backgroundColor = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 0.6)
        
    }
    
    private func prepareContentLabel() {
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = RobotoFont.regular(with: 14)
        contentLabel.backgroundColor = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 0.6)
        
    }
    
    private func prepareBottomBar() {
        bottomBar = Bar()
        bottomBar.heightPreset = .xlarge
        bottomBar.contentEdgeInsetsPreset = .square3
        bottomBar.centerViews = [dateLabel]
        bottomBar.leftViews = [favoriteButton]
        bottomBar.rightViews = [shareButton]
        bottomBar.dividerColor = Color.grey.lighten2
        bottomBar.backgroundColor = UIColor(red: 26/255, green: 188/255, blue: 155/255, alpha: 1)
    }
    
    private func preparePresenterCard() {
        card.toolbar = toolbar
        card.contentView = contentLabel
        card.contentViewEdgeInsetsPreset = .square3
        card.contentViewEdgeInsets.bottom = 0
        card.bottomBar = bottomBar
        card.depthPreset = .none
        card.clipsToBounds = true
        card.layer.cornerRadius = 20
        contentView.addSubview(card)
    }
    
}
