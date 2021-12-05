//
//  MyCell.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import Reusable
import SnapKit
import CoreLocation

protocol ResidencesListDelegate {
	func likeResidence(at row: Int)
	
	func openMapForResidence(at row: Int)
}

final class MyCustomCell: UITableViewCell, Reusable {
	let myBackground = UIView()
	let myLabel = UILabel()
	let customImageView = UIImageView()
	let distanceLabelView = UIView()
	let distanceLabel = UILabel()
	let likeButtonView = UIView()
	let likeImage = UIImageView(image: UIImage(systemName: "heart"))
	var delegate: ResidencesListDelegate?
	var rowIndex: Int?
	
	func configure(rowIndex: Int, residence: Residence, location: CLLocation? = nil, delegate: ResidencesListDelegate?) {
		self.rowIndex = rowIndex
		likeImage.image = residence.isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
		myBackground.backgroundColor = UIColor(white: 0, alpha: 0.05)
		addSubview(myBackground)
		myBackground.snp.makeConstraints { make in
			make.edges.equalTo(self).inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
		}
		myBackground.layer.cornerRadius = 20
		
		myLabel.text = residence.name
		myLabel.textAlignment = .center
		myLabel.numberOfLines = 3
		myBackground.addSubview(myLabel)
		
		customImageView.image = residence.images[0]
		customImageView.contentMode = .scaleAspectFill
		myBackground.addSubview(customImageView)
		customImageView.layer.cornerRadius = 20
		customImageView.clipsToBounds = true
		customImageView.snp.makeConstraints { make in
			make.top.equalTo(myBackground.snp.top)
			make.height.equalTo(myBackground.snp.height).dividedBy(1.5)
			make.left.equalTo(myBackground.snp.left)
			make.right.equalTo(myBackground.snp.right)
		}
		
		myLabel.snp.makeConstraints { make in
			make.height.equalTo(myBackground.snp.height).dividedBy(6)
			make.left.equalTo(myBackground.snp.left)
			make.right.equalTo(myBackground.snp.right)
			make.top.equalTo(customImageView.snp.bottom)
		}
		
		myBackground.addSubview(likeButtonView)
		likeButtonView.layer.cornerRadius = 20
		likeButtonView.backgroundColor = UIColor(white: 0, alpha: 0.1)
		likeButtonView.snp.makeConstraints { make in
			make.height.width.equalTo(40)
			make.left.equalTo(myBackground.snp.left).offset(6)
			make.bottom.equalTo(myBackground.snp.bottom).offset(-6)
		}
		
		self.delegate = delegate
		
		myBackground.isUserInteractionEnabled = true
		likeButtonView.isUserInteractionEnabled = true
		likeButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addToLiked)))
		
		likeButtonView.addSubview(likeImage)
		likeImage.snp.makeConstraints { make in
			make.edges.equalTo(likeButtonView).inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
		}
		likeImage.contentMode = .scaleAspectFill
		
		myBackground.addSubview(distanceLabelView)
		distanceLabelView.isUserInteractionEnabled = true
		distanceLabelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showOnMap)))
		
		distanceLabelView.snp.makeConstraints { make in
			make.bottom.equalTo(myBackground.snp.bottom).offset(-6)
			make.top.equalTo(myLabel.snp.bottom)
			make.left.equalTo(likeButtonView.snp.right).offset(10)
			make.right.equalTo(myBackground.snp.right).offset(-6)
		}
		distanceLabelView.backgroundColor = UIColor(white: 0, alpha: 0.1)
		distanceLabelView.layer.cornerRadius = 20
		distanceLabelView.addSubview(distanceLabel)
		
		distanceLabel.snp.makeConstraints { make in
			make.edges.equalTo(distanceLabelView)
		}
		
		distanceLabel.textAlignment = .center
		distanceLabel.textColor = UIColor(named: "AccentColor")
		
		if let location = location {
			let dist: Double = location.distance(from: CLLocation(latitude: residence.coordinates.latitude, longitude: residence.coordinates.longitude)) / 1000
			
			distanceLabel.text = "\(round(dist * 10) / 10) км от вас"
		} else {
			distanceLabel.text = "--- км от вас"
		}
	}
	
	@objc
	func addToLiked() {
		delegate?.likeResidence(at: rowIndex!)
	}
	
	@objc
	func showOnMap() {
		delegate?.openMapForResidence(at: rowIndex!)
	}
}
