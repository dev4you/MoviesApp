//
//  MasterViewController.swift
//  MoviesApp
//
//  Created by Satya Srinivas Volla on 6/13/17.
//  Copyright © 2017 Platinum. All rights reserved.
//

import UIKit
import Alamofire

class MasterViewController: UITableViewController {
    static let baseURL = "https://api.themoviedb.org/3/search/movie"
    static let apiKey = "ebfb93b3fd098d680cbfcc2d2ca5b900"
    static let pageSize = 20

    let searchController = UISearchController(searchResultsController: nil)
    var detailViewController: DetailViewController? = nil
    var filteredObjects = [Movie]()
    var currentPage:Int {
        return filteredObjects.count/MasterViewController.pageSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        refreshControl?.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Movies"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = filteredObjects[indexPath.row]
                let controller = segue.destination as! DetailViewController
                controller.detailItem = object
            }
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredObjects.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let object:Movie
        if searchController.isActive && searchController.searchBar.text != "" {
            object = filteredObjects[indexPath.row]
            cell.textLabel!.text = object.movieTitle
        }
        return cell
    }
    
    // MARK: - Custom Functions
    
    func loadMore() {
        if searchController.isActive && searchController.searchBar.text != "" {
            filterContentForSearchText(searchController.searchBar.text!)
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Service Call
    
    func filterContentForSearchText(_ searchText:String) {
        
        let nextPage = currentPage + 1

        let parameters:[String:Any] = ["api_key":MasterViewController.apiKey, "query":searchText, "page":nextPage]
        
        Alamofire.request(MasterViewController.baseURL, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: nil).validate(statusCode: 200..<500).responseJSON { response in
            switch response.result {
            case .success:
                if let dic = response.result.value as? [String: Any], let results = dic["results"] as? [[String: Any]]  {
                    for movie in results {
                        let m = Movie(movieId: movie["id"] as! Int, movieTitle: movie["title"] as! String)
                        self.filteredObjects.insert(m, at: 0)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

// MARK: - Protocol Extensions

extension MasterViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MasterViewController:UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        self.filteredObjects.removeAll()
        tableView.reloadData()
    }
}

