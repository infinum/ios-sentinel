//
//  MemoryInfoProvider.swift
//  Sentinel
//
//  Created by Nikola Majcen on 02/10/2020.
//

import Foundation

struct MemoryUsage {
    let used: Int64
    let total: Int64
}

struct MemoryInfoProvider {
    
    var currentUsage: MemoryUsage {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        let used = result == KERN_SUCCESS ? Int64(taskInfo.phys_footprint) : 0
        let total = Int64(ProcessInfo.processInfo.physicalMemory)
        return MemoryUsage(used: used, total: total)
    }
}
