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
	private let backView = UIView()
	weak var delegate: ViewController?
	
	var residenceToShow: Residence?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.frame = view.frame
		view.addSubview(mapView)
		navigationController?.navigationBar.isHidden = true
		goBackButton.image = UIImage(systemName: "chevron.backward.circle")
		view.addSubview(backView)
		backView.layer.cornerRadius = 25
		backView.addSubview(goBackButton)

		backView.isUserInteractionEnabled = true
		goBackButton.isUserInteractionEnabled = false
		backView.backgroundColor = UIColor(white: 0, alpha: 0.1)
		backView.snp.makeConstraints { make in
			make.top.equalTo(self.view.snp.top).offset(50)
			make.left.equalTo(view.snp.left).offset(15)
			make.height.width.equalTo(50)
		}
		
		backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
		
		goBackButton.snp.makeConstraints { make in
			make.edges.equalTo(backView)
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
												privaryButtonTitle: "Показать детали",
												secondaryButtonTitle: "Построить маршрут"))

		popupVC.tempateView.primaryButtonAction = { [weak self] in
			popupVC.pop { [weak self] in
				self?.showDetailViewController(for: residence)
			}
		}
		
		popupVC.tempateView.secondaryButtonAction = {
			guard let residence = residence else {
				return
			}
			let ymUrl = "yandexmaps://maps.yandex.ru/?pt=\(residence.coordinates.longitude),\(residence.coordinates.latitude)"
			guard let url = URL(string: ymUrl) else { return }
			UIApplication.shared.open(url)
		}
		
		popupVC.push(from: self)
		return true
	}
	
	func showDetailViewController(for residence: Residence?) {
		let detailsVC = DetailsViewController()
		detailsVC.residence = residence
		detailsVC.residences = self.residences
		self.navigationController?.pushViewController(detailsVC, animated: true)
	}
}
