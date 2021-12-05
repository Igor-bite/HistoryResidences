//
//  ViewController.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import SnapKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, ResidencesListDelegate {
	private var tableView: UITableView?
	private var residences = [Residence]()
	private let locationManager = CLLocationManager()
	private var previousLocation: CLLocationCoordinate2D? = nil {
		didSet {
			tableView?.reloadData()
		}
	}
	
	private var allResidences = [Residence]()
	private var isLikedOnly = false

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Резиденции"
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.backgroundColor = .white
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill")?.withTintColor(.orange), style: .plain, target: self, action: #selector(openMap))
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill")?.withTintColor(.orange), style: .plain, target: self, action: #selector(showLikedOnly))
		
		view.backgroundColor = .white
		setUpTableView()
		getResidences()
		
		locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
		let newLat = locValue.latitude
		let newLon = locValue.longitude
		guard let previousLocation = previousLocation else {
			self.previousLocation = locValue
			sortResidencesByDistance()
			return
		}

		if previousLocation.latitude - newLat > 0.0002 && previousLocation.longitude - newLon > 0.0002 {
			self.previousLocation = locValue
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func setUpTableView() {
		self.tableView = UITableView(frame: view.frame, style: .grouped)
		guard let tableView = tableView else { return }
		tableView.register(cellType: MyCustomCell.self)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.rowHeight = 300
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
		label.text = "    Выберите резиденцию"
		label.textColor = UIColor(white: 0, alpha: 0.5)
		label.backgroundColor = .white
		tableView.tableHeaderView = label
		view.addSubview(tableView)
	}
	
	public weak var vcToDismiss: UIViewController?
	
	@objc
	func openMap() {
		guard let _ = getApiToken() else {
			let ac = UIAlertController(title: "Can't find token", message: nil, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			self.present(ac, animated: true)
			return
		}
		let mapVC = MapViewController()
		mapVC.residences = residences
		mapVC.delegate = self
		let nav = UINavigationController(rootViewController: mapVC)
		nav.modalPresentationStyle = .fullScreen
		self.present(nav, animated: true)
	}
	
	private func getApiToken() -> String? {
		var resourceFileDictionary: NSDictionary?
			
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
			resourceFileDictionary = NSDictionary(contentsOfFile: path)
		}
		
		if let resourceFileDictionaryContent = resourceFileDictionary {
			let token = resourceFileDictionaryContent.object(forKey: "YandexMapsToken") as? String
			if token == "" {
				return nil
			}
			return token
		} else { return nil }
	}
	
	@objc
	func showLikedOnly() {
		var noChanges = false
		if isLikedOnly {
			residences = allResidences
			title = "Резиденции"
		} else {
			residences = allResidences.filter({ residence in
				return residence.isLiked
			})
			if residences.isEmpty {
				residences = allResidences
				let ac = UIAlertController(title: "У вас пока нет избранных резиденций", message: "Резиденцию можно добавить в избранное нажав на сердечко", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "Ясно", style: .cancel))
				self.present(ac, animated: true)
				noChanges = true
			} else {
				title = "Избранное"
			}
		}
		if !noChanges {
			isLikedOnly.toggle()
			tableView?.reloadData()
			self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		}
	}
	
	private func getResidences() {
		for file in 1...30 {
			if let res = parseJsonFile(filename: String(file)) {
				let residence = Residence(dto: res, delegate: self.tableView, indexPathToUpdate: IndexPath(row: file - 1, section: 0))
				allResidences.append(residence)
			}
		}
		if let location = self.previousLocation {
			let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
			allResidences.sort { res1, res2 in
				let dist1: Double = loc.distance(from: CLLocation(latitude: res1.coordinates.latitude, longitude: res1.coordinates.longitude))
				let dist2: Double = loc.distance(from: CLLocation(latitude: res2.coordinates.latitude, longitude: res2.coordinates.longitude))
					
				return dist1 < dist2
			}
		}
		residences = allResidences
	}
	
	func sortResidencesByDistance() {
		if let location = self.previousLocation {
			let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
			residences.sort { res1, res2 in
				let dist1: Double = loc.distance(from: CLLocation(latitude: res1.coordinates.latitude, longitude: res1.coordinates.longitude))
				let dist2: Double = loc.distance(from: CLLocation(latitude: res2.coordinates.latitude, longitude: res2.coordinates.longitude))
					
				return dist1 < dist2
			}
			allResidences.sort { res1, res2 in
				let dist1: Double = loc.distance(from: CLLocation(latitude: res1.coordinates.latitude, longitude: res1.coordinates.longitude))
				let dist2: Double = loc.distance(from: CLLocation(latitude: res2.coordinates.latitude, longitude: res2.coordinates.longitude))
					
				return dist1 < dist2
			}
		}
		tableView?.reloadData()
	}
	
	private func parseJsonFile(filename: String) -> ResidenceDTO? {
		if let path = Bundle.main.path(forResource: filename, ofType: "json") {
			do {
				let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
				return try? JSONDecoder().decode(ResidenceDTO.self, from: jsonData)
			} catch {
				return nil
			}
		}
		return nil
	}
	
	func push(vc: UIViewController) {
		vcToDismiss?.dismiss(animated: true, completion: {
			self.navigationController?.pushViewController(vc, animated: true)
		})
	}
	
	func likeResidence(at row: Int) {
		self.residences[row].isLiked.toggle()
		let manager = UserDefaults.standard
		manager.set(self.residences[row].isLiked, forKey: self.residences[row].name)
		let res = allResidences.first { residence in
			return residence.isEqual(self.residences[row])
		}
		res?.isLiked = self.residences[row].isLiked
		if isLikedOnly {
			residences = residences.filter({ residence in
				return residence.isLiked
			})
			if residences.isEmpty {
				residences = allResidences
				title = "Резиденции"
				isLikedOnly = false
				let ac = UIAlertController(title: "Теперь у вас нет избранных резиденций", message: nil, preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "Ясно", style: .cancel))
				self.present(ac, animated: true)
			}
			self.tableView?.reloadData()
		} else {
			self.tableView?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
		}
	}
	
	func openMapForResidence(at row: Int) {
		guard let _ = getApiToken() else {
			let ac = UIAlertController(title: "Can't find token", message: nil, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			self.present(ac, animated: true)
			return
		}
		let mapVC = MapViewController()
		mapVC.residences = residences
		mapVC.residenceToShow = residences[row]
		mapVC.delegate = self
		let nav = UINavigationController(rootViewController: mapVC)
		nav.modalPresentationStyle = .fullScreen
		self.present(nav, animated: true)
	}
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MyCustomCell.self)
		let res = residences[indexPath.row]
		cell.contentView.isUserInteractionEnabled = true
		
		if let location = previousLocation {
			cell.configure(rowIndex: indexPath.row, residence: res, location: CLLocation(latitude: location.latitude, longitude: location.longitude), delegate: self)
		} else {
			cell.configure(rowIndex: indexPath.row, residence: res, delegate: self)
		}
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return residences.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let detailsVC = DetailsViewController()
		detailsVC.residence = residences[indexPath.row]
		detailsVC.residences = residences
		navigationController?.pushViewController(detailsVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MyCustomCell.self)
		
		cell.snp.removeConstraints()
	}
}
