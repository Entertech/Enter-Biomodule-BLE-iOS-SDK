//
//  DFUPacketFilesViewController.swift
//  BLETool
//
//  Created by Anonymous on 2018/1/30.
//  Copyright © 2018年 EnterTech. All rights reserved.
//

import UIKit

class DFUPacketFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var files: [URL]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.startMonitoringDocumentAsynchronous()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_identifier = "cell_identifier_unique"

        let cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cell_identifier) {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: cell_identifier)
        }

        cell.textLabel?.text = self.files[indexPath.row].lastPathComponent

        return cell
    }

    private func startMonitoringDocumentAsynchronous() {
        files = [URL]()
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first
        do {
            try files = FileManager.default.contentsOfDirectory(at: URL(string: path!)!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for file in files {
                print("-----------\(file.absoluteString)")
            }
        } catch {
            print("Error \(error)")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Persistence.shared.dfuPacketURL = self.files[indexPath.row]
        Persistence.shared.dfuPacketName = self.files[indexPath.row].lastPathComponent
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
