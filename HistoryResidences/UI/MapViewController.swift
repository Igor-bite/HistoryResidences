//
//  MapViewController.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import YandexMapsMobile
import SnapKit
import ALPopup

class MapViewController: UIViewController {
	private var mapView = YMKMapView()
	var residences : [Residence]?
	private let backButton = UILabel()
	private let goBackButton = UIImageView()
	weak var delegate: ViewController?
	
	var residenceToShow: Residence?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.frame = view.frame
		view.addSubview(mapView)
		
		goBackButton.image = UIImage(systemName: "chevron.backward.circle")
		view.addSubview(goBackButton)

		let backGR = UITapGestureRecognizer(target: self, action: #selector(goBack))
		goBackButton.isUserInteractionEnabled = true
		goBackButton.addGestureRecognizer(backGR)

		goBackButton.snp.makeConstraints { make in
			make.top.equalTo(self.view.snp.top).offset(50)
			make.left.equalTo(view.snp.left).offset(15)
			make.height.width.equalTo(40)
		}
		
		let mapObjects = mapView.mapWindow.map.mapObjects
		mapObjects.addTapListener(with: self)
		
		addResidences()
		
		if let residenceToShow = residenceToShow {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
				self?.mapView.mapWindow.map.move(
					with: YMKCameraPosition(target: YMKPoint(latitude: residenceToShow.coordinates.latitude, longitude: residenceToShow.coordinates.longitude), zoom: 15, azimuth: 0, tilt: 0),
							animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2),
							cameraCallback: nil)
			}
		}
	}
	
	@objc
	func goBack() {
		self.dismiss(animated: true)
	}
	
	func addResidences() {
		guard let residences = residences else { return }
		let mapObjects = mapView.mapWindow.map.mapObjects
		for residence in residences {
			let point = YMKPoint(latitude: residence.coordinates.latitude, longitude: residence.coordinates.longitude)
			let placemark = mapObjects.addPlacemark(with: point)
			placemark.userData = residence
			placemark.opacity = 1
			placemark.isDraggable = false
			placemark.setIconWith(UIImage(systemName: "house")!)
		}
	}
}

extension MapViewController: YMKMapObjectTapListener {
	func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
		let residence = mapObject.userData as? Residence
		let popupVC = ALPopup.card(template: .init(title: "Резиденция" ,
												subtitle: residence?.name,
												image: residence?.images[0],
												privaryButtonTitle: "Open",
												secondaryButtonTitle: "Not Now"))

		popupVC.tempateView.primaryButtonAction = { [weak self] in
			popupVC.pop { [weak self] in
				self?.showDetailViewController(for: residence)
			}
		}
		
		popupVC.tempateView.secondaryButtonAction = {
			popupVC.pop()
		}
		
		popupVC.push(from: self)
		return true
	}
	
	func showDetailViewController(for residence: Residence?) {
		let detailsVC = DetailsViewController()
		detailsVC.residence = residence
		detailsVC.residences = self.residences
		self.navigationController?.pushViewController(detailsVC, animated: true)
//		delegate?.vcToDismiss = self
//		delegate?.push(vc: detailsVC)
	}
}
