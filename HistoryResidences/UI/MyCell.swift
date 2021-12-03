//
//  MyCell.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import Reusable
import SnapKit

final class MyCustomCell: UITableViewCell, Reusable {
	let myBackground = UIView()
	let myLabel = UILabel()
	let customImageView = UIImageView()
	
	func configure(residence: Residence) {
		myBackground.backgroundColor = UIColor(white: 0, alpha: 0.05)
		addSubview(myBackground)
		myBackground.snp.makeConstraints { make in
			make.edges.equalTo(self).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
		}
		myBackground.layer.cornerRadius = 20
		
		myLabel.text = residence.name
		myLabel.textAlignment = .center
		myLabel.numberOfLines = 3
		myBackground.addSubview(myLabel)
		
		myLabel.snp.makeConstraints { make in
			make.bottom.equalTo(myBackground.snp.bottom)
			make.centerY.equalTo(myBackground.snp.centerY)
			make.height.equalTo(myBackground.snp.height).dividedBy(3)
			make.width.equalTo(myBackground.snp.width)
		}
		
		customImageView.image = residence.images[0]
		customImageView.contentMode = .scaleAspectFill
		myBackground.addSubview(customImageView)
		customImageView.layer.cornerRadius = 20
		customImageView.clipsToBounds = true
		customImageView.snp.makeConstraints { make in
			make.top.equalTo(myBackground.snp.top)
			make.bottom.equalTo(myLabel.snp.top)
			make.centerY.equalTo(myBackground.snp.centerY)
			make.width.equalTo(myBackground.snp.width)
		}
	}
}
