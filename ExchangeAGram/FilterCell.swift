//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Trevor Griffin on 1/31/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
