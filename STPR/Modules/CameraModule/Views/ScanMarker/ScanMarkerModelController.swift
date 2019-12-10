//
//  ScanMarkerModelController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/26/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Kingfisher
import Combine

final class ScanMarkerModelController {
    typealias Dependencies = HasImageDownloader

    @Published private(set) var marker: CGImage? = nil
    @Published private(set) var overlay: CGImage? = nil
    
    let scanMarkerData: ScanMarkerData

    private let imageDownloader: ImageDownloaderType
    private var cancellables: Set<AnyCancellable> = []

    init(scanMarkerData: ScanMarkerData, dependencies: Dependencies) {
        self.imageDownloader = dependencies.imageDownloader
        self.scanMarkerData = scanMarkerData
    }

    func fetch() {
        fetchImage(from: scanMarkerData.markerUrl)
            .retry(3)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { self.marker = $0.cgImage }
            ).store(in: &cancellables)

        if let overlayURL = scanMarkerData.overlayUrl {
            fetchImage(from: overlayURL)
                .retry(3)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { self.overlay = $0.cgImage }
                ).store(in: &cancellables)
        }
    }

    private func fetchImage(from url: String) -> AnyPublisher<UIImage, Error> {
        Just(url)
            .setFailureType(to: Error.self)
            .compactMap { URL(string: $0) }
            .flatMap { self.imageDownloader.downloadImage(using: $0) }
            .eraseToAnyPublisher()
    }
}
