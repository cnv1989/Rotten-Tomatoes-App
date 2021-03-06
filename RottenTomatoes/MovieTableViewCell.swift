    //
//  MovieTableViewCell.swift
//  RottenTomatoes
//
//  Created by Nag Varun Chunduru on 9/11/14.
//  Copyright (c) 2014 cnv. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var audienceScore: UILabel!
    @IBOutlet weak var pgRating: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var casts: UILabel!
}
