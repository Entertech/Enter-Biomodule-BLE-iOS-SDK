//
//  FileListViewController.swift
//  EnterBioModuleBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import Files
import SVProgressHUD

class FileListViewController: UITableViewController {

    private var _files: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        do {
            _files = try Folder(path: FileManager.default.dataDirectory.path).files.map { URL(fileURLWithPath: $0.path) }
        } catch {
            SVProgressHUD.showError(withStatus: "Failed to scan files!")
        }
    }

    @IBAction func closeButtonTouched(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCellIdentifier", for: indexPath)
        let fileURL = _files[indexPath.row]
        cell.textLabel?.text = fileURL.lastPathComponent
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] as? UInt {
            cell.detailTextLabel?.text = "size: " + String(fileSize) + "B"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let file = _files[indexPath.row]
        do {
            try FileManager.default.removeItem(at: file)
            _files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            SVProgressHUD.showError(withStatus: "Failed to remove file!")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SVProgressHUD.showInfo(withStatus: "Select【Mail】or【Copy to WeChat】")

        let file = _files[indexPath.row]
        // 只能分享到微信
        let activity = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }

}
