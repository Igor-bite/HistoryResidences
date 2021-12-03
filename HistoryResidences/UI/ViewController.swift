//
//  ViewController.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
	private var tableView: UITableView?
	private var residences = [Residence]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Резиденции"
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.backgroundColor = .white
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill")?.withTintColor(.orange), style: .plain, target: self, action: #selector(openMap))
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.fill")?.withTintColor(.orange), style: .plain, target: self, action: #selector(openUserProfile))
		
		view.backgroundColor = .white
		setUpTableView()
		getResidences()
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
		
//		tableView.snp.makeConstraints { make in
//			make.top.equalTo(self.view.snp.top)
//			make.right.equalTo(self.view.snp.right)
//			make.left.equalTo(self.view.snp.left)
//			make.bottom.equalTo(self.view.snp.bottom)
//		}
	}
	
	public weak var vcToDismiss: UIViewController?
	
	@objc
	func openMap() {
		let mapVC = MapViewController()
		mapVC.residences = residences
		mapVC.delegate = self
		let nav = UINavigationController(rootViewController: mapVC)
		nav.modalPresentationStyle = .fullScreen
		self.present(nav, animated: true)
	}
	
	@objc
	func openUserProfile() {
		let vc = ProfileViewController()
		present(vc, animated: true)
	}
	
	private func getResidences() {
		for file in 1...30 {
			if let res = parseJsonFile(filename: String(file)) {
				residences.append(Residence(dto: res, delegate: self.tableView, indexPathToUpdate: IndexPath(row: file - 1, section: 0)))
			}
		}
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
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MyCustomCell.self)
		let res = residences[indexPath.row]
		cell.configure(residence: res)
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
