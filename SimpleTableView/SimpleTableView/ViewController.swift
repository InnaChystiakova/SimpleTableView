//
//  ViewController.swift
//  SimpleTableView
//
//  Created by Инна Чистякова on 10.07.2023.
//

import UIKit

enum Section: Hashable {
    case main
}

struct Bugs: Hashable {
    let title: String
}

class ViewController: UIViewController, UITableViewDelegate {
    
    // MARK: Constants
    
    let navTitle: String = "Список тараканов"
    let navButtonTitle: String = "Шухер!"
        
    // MARK: Properties
    
    let simpleTableView: UITableView = UITableView.init(frame: .zero, style: .plain)
    
    lazy var bugs: [Bugs] = {
        var busket: [Bugs] = []
        for number in 1...50 {
            busket.append(Bugs(title: "\(number)-й таракан"))
        }
        return busket
    }()
    
    var selectedBugs: [Bugs] = []
    var dataSource: UITableViewDiffableDataSource <Section, Bugs>!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
       
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        simpleTableView.frame = CGRect(
            x: view.layoutMargins.left,
            y: view.layoutMargins.top,
            width: view.frame.size.width - view.layoutMargins.right - view.layoutMargins.left,
            height: view.frame.size.height - view.layoutMargins.top - view.layoutMargins.bottom
        )
    }
    
    // MARK: Setup
    
    func setupNavigationBar() {
        title = navTitle

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: navButtonTitle,
            style: .plain,
            target: self,
            action: #selector(mixElements)
        )
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func mixElements() {
        bugs.shuffle()
        updateDataSource()
    }
    
    func setupTableView() {
        simpleTableView.register(BugCell.self, forCellReuseIdentifier: "BugCell")
        simpleTableView.delegate = self
        simpleTableView.allowsMultipleSelection = true
                
        dataSource = UITableViewDiffableDataSource( tableView: simpleTableView, cellProvider: { tableView, indexPath, bug in
            let cell = tableView.dequeueReusableCell(withIdentifier: "BugCell", for: indexPath)
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = bug.title
            cell.contentConfiguration = configuration
            
            if self.selectedBugs.contains(bug) {
                cell.accessoryType = .checkmark
            }
            return cell
        })
        
        updateDataSource()
        
        view.addSubview(simpleTableView)
    }
    
    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Bugs>()
        snapshot.appendSections([.main])
        snapshot.appendItems(bugs)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let bug = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let topBug = dataSource.itemIdentifier(for: IndexPath(row: 0, section: indexPath.section)) else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.moveItem(bug, beforeItem: topBug)
        dataSource.apply(snapshot, animatingDifferences: true)

        cell.accessoryType = .checkmark
        cell.selectionStyle = .none

        selectedBugs.append(bug)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let bug = dataSource.itemIdentifier(for: indexPath) else { return }
                
        cell.accessoryType = .none

        if let index = selectedBugs.firstIndex(of: bug) {
            selectedBugs.remove(at: index)
        }
    }
}

class BugCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        selectionStyle = .none
    }
}

