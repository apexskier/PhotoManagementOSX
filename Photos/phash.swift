//
//  phash.swift
//  Photos
//
//  Created by Cameron Little on 11/22/14.
//  Copyright (c) 2014 Cameron Little. All rights reserved.
//

import Foundation
import AppKit

func phash(img: NSImage) -> Int64 {
    img.resizingMode = NSImageResizingMode(rawValue: <#Int#>)
    img.size = NSSize(width: 32, height: 32)
    
    
}
/// 1. Reduce size to 32x32. (reduce high frequencies)

/// 2. Reduce to a grayscale.

/// 3. Compute the DCT.

/// 4. Reduce the DCT.

/// 5. Compute the average value.

/// 6. Further reduce the DCT.

/// 7. Construct the hash. Set the 64 bits into a 64-bit integer.
