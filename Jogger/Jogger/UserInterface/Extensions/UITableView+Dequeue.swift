//
//  UITableView+Dequeue.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - UITableView+Dequeue

extension UITableView {

    /// Dequeues a cell of type `T` for the given `indexPath`. Assumes the cell is registered with an identifier
    /// identical to its class name.
    ///
    /// - parameter cellType: The type of cell to dequeue.
    /// - parameter indexPath: The indexPath of the cell to dequeue.
    /// - returns: The dequeued cell.
    func dequeueCell<T: UITableViewCell>(ofType cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: "\(cellType)", for: indexPath) as! T
    }
}
