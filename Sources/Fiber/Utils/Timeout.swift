/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************
 *  This file contains code that has not yet been described                   *
 ******************************************************************************/

import Time
import Platform

extension Time {
#if os(macOS) || os(iOS)
    var kqueueMaximumTimeout: Time.Duration {
        return (60*60*24).s
    }

    var timeoutSinceNow: timespec {
        guard self < .now + kqueueMaximumTimeout else {
            return timespec(
                tv_sec: kqueueMaximumTimeout.seconds,
                tv_nsec: kqueueMaximumTimeout.nanoseconds)
        }
        let duration = timeIntervalSinceNow.duration
        return timespec(tv_sec: duration.seconds, tv_nsec: duration.nanoseconds)
    }
#else
    var timeoutSinceNow: Int32 {
        guard self < Time.distantFuture else {
            return Int32.max
        }
        let timeout = timeIntervalSinceNow.duration.ms
        guard timeout < Int(Int32.max) else {
            return Int32.max
        }
        return Int32(timeout)
    }
#endif
}
