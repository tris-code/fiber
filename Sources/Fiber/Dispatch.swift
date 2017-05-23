/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Platform
import Dispatch

import struct Foundation.Date

extension FiberLoop {
    public func dispatch<T>(
        deadline: Date = Date.distantFuture,
        task: @escaping () throws -> T
    ) throws -> T {
        var result: T? = nil
        var taskError: Error? = nil

        let fd = try pipe()

        try wait(for: fd.1, event: .write, deadline: deadline)

        DispatchQueue.global(qos: .background).async {
            do {
                result = try task()
            } catch {
                taskError = error
            }
            var done: UInt8 = 1
            write(fd.1, &done, 1)
        }

        try wait(for: fd.0, event: .read, deadline: deadline)

        close(fd.0)
        close(fd.1)

        if let taskError = taskError {
            throw taskError
        } else if let result = result {
            return result
        } else {
            fatalError()
        }
    }

    fileprivate func pipe() throws -> (Descriptor, Descriptor) {
        var fd: (Descriptor, Descriptor) = (0, 0)
        let pointer = UnsafeMutableRawPointer(&fd)
            .assumingMemoryBound(to: Int32.self)
        guard Platform.pipe(pointer) != -1 else {
            throw SystemError()
        }
        return fd
    }
}
