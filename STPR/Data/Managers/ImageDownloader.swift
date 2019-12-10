//
//  ImageDownloader.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/26/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Kingfisher
import Combine

protocol ImageDownloaderType {
    func downloadImage(using url: URL) -> AnyPublisher<UIImage, Error>
}

extension ImageDownloader: ImageDownloaderType {
    func downloadImage(using url: URL) -> AnyPublisher<UIImage, Error> {
        Future { promise in
            self.downloadImage(with: url) { result in
                promise(result.map { $0.image })
            }
        }
        .mapError { $0 }
        .eraseToAnyPublisher()
    }
}
