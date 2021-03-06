/**
 * Copyright (c) 2016-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Bolts
import BoltsSwift

let unknownDomain = "unknown"

func objcTask<T where T: AnyObject>(task: Task<T>) -> BFTask {
    let taskCompletionSource = BFTaskCompletionSource()
    task.continueWith { task in
        if task.cancelled {
            taskCompletionSource.trySetCancelled()
        } else if task.faulted {
            let error = task.error as? NSError ?? NSError(domain: unknownDomain, code: -1, userInfo: nil)
            taskCompletionSource.trySetError(error)
        } else {
            taskCompletionSource.trySetResult(task.result)
        }
    }
    return taskCompletionSource.task
}

func swiftTask(task: BFTask) -> Task<AnyObject> {
    let taskCompletionSource = TaskCompletionSource<AnyObject>()
    task.continueWithBlock { task in
        if task.cancelled {
            taskCompletionSource.tryCancel()
        } else if let error = task.error where task.faulted {
            taskCompletionSource.trySet(error: error)
        } else if let result = task.result {
            taskCompletionSource.trySet(result: result)
        } else {
            fatalError("Unknown task state")
        }
        return nil
    }
    return taskCompletionSource.task
}
