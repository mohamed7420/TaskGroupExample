//
//  ViewController.swift
//  TaskGroup
//
//  Created by MohamedOsama on 08/06/2023.
//

import UIKit

class ImageTVCell: UITableViewCell {
    
    override var reuseIdentifier: String? {
        return String(describing: Self.self)
    }
    
    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(cellImageView)
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            cellImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5),
            cellImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            cellImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5),
            cellImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    public func configureCell(image: UIImage) {
        cellImageView.image = image
    }
}

class ViewController: UIViewController {
    
    enum ImageLoading: Error {
        case errorWhileLoading
    }
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(ImageTVCell.self, forCellReuseIdentifier: String(describing: ImageTVCell.self))
        return table
    }()
    
    private var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        Task {
            let images = try await self.loadAllImages()
            self.images = images
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func loadView() {
        super.loadView()
        tableView.frame = view.bounds
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadAllImages() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images = [UIImage]()
            group.addTask {
                try await self.loadImage(url: "https://picsum.photos/200")
            }
            
            group.addTask {
                try await self.loadImage(url: "https://picsum.photos/210")
            }
            
            group.addTask {
                try await self.loadImage(url: "https://picsum.photos/220")
            }
            
            for try await image in group {
                images.append(image)
            }
            return images
        }
    }

    private func loadImage(url: String) async throws -> UIImage {
        
        guard let url = URL(string: url) else {
            throw ImageLoading.errorWhileLoading
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: nil)
            guard let image = UIImage(data: data) else {
                throw ImageLoading.errorWhileLoading
            }
            return image
        } catch {
            throw error
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ImageTVCell.self)", for: indexPath) as! ImageTVCell
        cell.configureCell(image: images[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
}
