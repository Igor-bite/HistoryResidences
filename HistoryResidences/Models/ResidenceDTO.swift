//
//  Residence.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit

class ResidenceDTO : Codable {
	var name: String
	var images: [String]
	var description: String
	var coordinates: Coordinates
	var address: String
	
	init(name: String, image: String, description: String, address: String, coord: Coordinates) {
		self.name = name
		self.images = [image]
		self.description = description
		self.address = address
		self.coordinates = coord
	}
	
	init(name: String, images: [String], description: String, address: String, coord: Coordinates) {
		self.name = name
		self.images = images
		self.description = description
		self.address = address
		self.coordinates = coord
	}
}

class Coordinates : Codable {
	var longitude: CGFloat
	var latitude: CGFloat
	
	init(longitude: CGFloat, latitude: CGFloat) {
		self.longitude = longitude
		self.latitude = latitude
	}
}

class Residence {
	var name: String
	var images: [UIImage]
	var description: String
	var coordinates: Coordinates
	var address: String
	weak var delegate: UITableView?
	var isLiked: Bool = false
	
	init(dto: ResidenceDTO, delegate: UITableView?, indexPathToUpdate: IndexPath) {
		self.name = dto.name
		self.images = [UIImage](repeating: UIImage(), count: dto.images.count)
		self.description = dto.description
		self.address = dto.address
		self.coordinates = dto.coordinates
		self.delegate = delegate
		restoreLike()
		self.dispatchImagesLoad(links: dto.images, indexPathToUpdate: indexPathToUpdate)
	}
	
	private func dispatchImagesLoad(links: [String], indexPathToUpdate: IndexPath) {
		let loader = ImageLoader()
		for (i, link) in links.enumerated() {
			DispatchQueue.global().async {
				loader.imageFromServerURL(link) { result in
					switch result {
					case .failure(let error):
						print(error.localizedDescription)
					case .success(let image):
						DispatchQueue.main.async {
							self.images[i] = image
							self.delegate?.reloadRows(at: [indexPathToUpdate], with: .fade)
						}
					}
				}
			}
		}
	}
	
	private func restoreLike() {
		let manager = UserDefaults.standard
		self.isLiked = manager.bool(forKey: name)
	}
	
	func isEqual(_ other: Residence) -> Bool {
		if name == other.name &&
			address == other.address {
			return true
		}
		return false
	}
}
