//
//  HealthKitManager.swift
//  Pawgress
//
//  Created by Emma Mazzoni on 4/28/26.
//

import HealthKit
import SwiftData
import Combine

class HealthKitManager: ObservableObject{
    let healthStore = HKHealthStore()
    
    // we only need to read workouts from healthkit no writing back
    private let typesToRead: Set = [
        HKObjectType.workoutType()
    ]
    
    func requestAuthorization(completion: @escaping (Bool) -> Void){
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead){success, error in
            completion(success)
        }
    }
    
    func fetchRecentWorkouts(since date: Date, completion: @escaping ([HKWorkout]) -> Void){
        let predicate = HKQuery.predicateForSamples(withStart: date, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]){_, sample, error in
            guard let workouts = sample as? [HKWorkout] else{
                completion([])
                return
            }
            completion(workouts)
        }
        healthStore.execute(query)
    }
}
