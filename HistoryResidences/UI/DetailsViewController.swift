//
//  DetailsViewController.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import SnapKit

class DetailsViewController: UIViewController, UIScrollViewDelegate {
	weak var residence: Residence?
	var residences: [Residence]?

	private let goBackButton = UIImageView()
	private let residenceTitle = UIButton()
	private let residenceDetails = UITextView()
	private let locationView = UIView()
	
	private static let partForImage = 3.0
	let scrollView = UIScrollView()
	let imagesScrollView = UIScrollView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height / DetailsViewController.partForImage))
	var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	var pageControl : UIPageControl = UIPageControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationController?.setNavigationBarHidden(true, animated: true)

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

		residenceTitle.setTitle(residence?.name, for: .normal)
		residenceTitle.titleLabel?.isHidden = false
		residenceTitle.setTitleColor(.black, for: .normal)
		residenceTitle.titleLabel?.textAlignment = .center
		residenceTitle.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
		residenceTitle.titleLabel?.numberOfLines = 2
		residenceTitle.titleLabel?.textColor = .black
		residenceTitle.isUserInteractionEnabled = false
		residenceTitle.contentVerticalAlignment = .top
		residenceTitle.contentHorizontalAlignment = .center
		residenceTitle.autoresizesSubviews = true
		residenceTitle.autoresizingMask = .flexibleWidth
		view.addSubview(residenceTitle)
		
		residenceTitle.snp.makeConstraints { make in
			make.top.equalTo(goBackButton.snp.top)
			make.left.equalTo(goBackButton.snp.right).offset(5)
			make.right.equalTo(self.view.snp.right).offset(-10)
			make.height.equalTo(70)
		}
		
		imagesScrollView.delegate = self
		imagesScrollView.isPagingEnabled = true
		imagesScrollView.showsHorizontalScrollIndicator = false
		imagesScrollView.showsVerticalScrollIndicator = false

		self.view.addSubview(imagesScrollView)
		
		imagesScrollView.snp.makeConstraints { make in
			make.top.lessThanOrEqualTo(residenceTitle.snp.bottom)
			make.centerX.equalTo(view.snp.centerX)
			make.height.equalTo(view.snp.height).dividedBy(Self.partForImage)
			make.width.equalTo(view.snp.width)
		}
		
		let gap = 10.0
		for index in 0..<(residence?.images.count ?? 0) {
			frame.origin.x = gap + (self.imagesScrollView.frame.size.width) * CGFloat(index)
			frame.size = CGSize(width: self.imagesScrollView.frame.width - 2 * gap, height: self.imagesScrollView.frame.height)

			let imageView = UIImageView(frame: frame)
			imageView.image = residence?.images[index]
			imageView.contentMode = .scaleAspectFill
			imageView.layer.cornerRadius = 20
			imageView.clipsToBounds = true
			self.imagesScrollView.addSubview(imageView)
		}
		
		self.imagesScrollView.contentSize = CGSize(width: self.imagesScrollView.frame.size.width * CGFloat((residence?.images.count ?? 0)), height: self.imagesScrollView.frame.size.height)
		pageControl.addTarget(self, action: #selector(changePage(sender:)), for: .valueChanged)

		configurePageControl()

		view.addSubview(locationView)
		let pinImage = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
		pinImage.contentMode = .scaleAspectFit
		locationView.addSubview(pinImage)
		let placeName = UILabel()
		placeName.text = residence?.address
		placeName.numberOfLines = 2
		locationView.addSubview(placeName)
		
		let tapRec = UITapGestureRecognizer(target: self, action: #selector(openMap))
		locationView.addGestureRecognizer(tapRec)

		locationView.snp.makeConstraints { make in
			make.height.equalTo(50)
			make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-5)
			make.left.equalTo(30)
			make.right.equalTo(-30)
		}

		pinImage.snp.makeConstraints { make in
			make.left.equalTo(locationView.snp.left)
			make.height.width.equalTo(locationView.snp.height)
		}

		placeName.snp.makeConstraints { make in
			make.left.equalTo(pinImage.snp.right).offset(10)
			make.right.equalTo(locationView.snp.right)
			make.height.equalTo(locationView.snp.height)
		}

		residenceDetails.text = residence?.description
		residenceDetails.font = UIFont.systemFont(ofSize: 15)
		residenceDetails.isEditable = false
		view.addSubview(residenceDetails)

		residenceDetails.snp.makeConstraints { make in
			make.centerX.equalTo(view.snp.centerX)
			make.left.equalTo(view.snp.left).offset(10)
			make.right.equalTo(view.snp.right).offset(-10)
			make.top.equalTo(pageControl.snp.bottom)
			make.bottom.equalTo(locationView.snp.top).offset(-5)
		}
	}
	
	@objc
	func openMap() {
		guard let _ = getApiToken() else {
			let ac = UIAlertController(title: "Can't find token", message: nil, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			self.present(ac, animated: true)
			return
		}
		guard let residence = residence else {
			return
		}

		let ymUrl = "yandexmaps://maps.yandex.ru/?pt=\(residence.coordinates.longitude),\(residence.coordinates.latitude)"
		guard let url = URL(string: ymUrl) else { return }
		UIApplication.shared.open(url)
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
	func goBack() {
		navigationController?.popViewController(animated: true)
	}
	
	func configurePageControl() {
		self.pageControl.numberOfPages = residence?.images.count ?? 0
		self.pageControl.currentPage = 0
		self.pageControl.tintColor = UIColor.red
		self.pageControl.pageIndicatorTintColor = UIColor.gray
		self.pageControl.currentPageIndicatorTintColor = UIColor(named: "AccentColor")
		self.view.addSubview(pageControl)
		pageControl.snp.makeConstraints { make in
			make.top.equalTo(imagesScrollView.snp.bottom)
			make.left.equalTo(imagesScrollView.snp.left)
			make.right.equalTo(imagesScrollView.snp.right)
			make.height.equalTo(50)
		}
	}

	@objc
	func changePage(sender: AnyObject) -> () {
		let x = CGFloat(pageControl.currentPage) * imagesScrollView.frame.size.width
		imagesScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}
