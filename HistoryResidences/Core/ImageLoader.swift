//
//  ImageLoader.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 09.11.2021.
//

import UIKit

typealias completionHandler = (Result<UIImage, Error>) -> Void

class ImageLoader {
	func imageFromServerURL(_ URLString: String, completion: @escaping completionHandler) {
		let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		
		if let url = URL(string: imageServerUrl) {
			URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
				if let error = error {
					completion(.failure(error))
					return
				}
				if let data = data {
					if let downloadedImage = UIImage(data: data) {
						completion(.success(downloadedImage))
					}
				}
			}).resume()
		}
	}
}
