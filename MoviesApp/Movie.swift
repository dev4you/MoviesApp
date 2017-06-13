//
//  Movie.swift
//  MoviesApp
//
//  Created by Satya Srinivas Volla on 6/13/17.
//  Copyright © 2017 Platinum. All rights reserved.
//

import Foundation

struct Movie {
    let movieId:Int
    let movieTitle:String
    
    init(movieId:Int, movieTitle:String) {
        self.movieId = movieId
        self.movieTitle = movieTitle
    }
}
