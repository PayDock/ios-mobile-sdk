//
//  MoviesService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

protocol MoviesService {

    func getTopRated() async throws -> TopRated
    func getMovieDetail(id: Int) async throws -> MovieModel

}

struct MoviesServiceImpl: HTTPClient, MoviesService {

    func getTopRated() async throws -> TopRated {
        return try await sendRequest(endpoint: MoviesEndpoint.topRated, responseModel: TopRated.self)
    }

    func getMovieDetail(id: Int) async throws -> MovieModel {
        return try await sendRequest(endpoint: MoviesEndpoint.movieDetail(id: id), responseModel: MovieModel.self)
    }

}
