import UIKit
 

class LunaRDailyTrackerPacket: LunaRPacket {
    fileprivate let HEADERLENGTH:Int = 5;
    fileprivate let HOURLYPACKETSNUMBER:Int = 2;
    /**
     get Packet data timer
     
     :returns: timer/Year,Month,Day
     */
    func getDate()->Date{
        var year:Int = Int(NSData2Bytes(getPackets()[0])[2] )
        year = year + Int(NSData2Bytes(getPackets()[0])[3] )<<8
        let month:Int = Int(NSData2Bytes(getPackets()[0])[4])
        let day:Int = Int(NSData2Bytes(getPackets()[0])[5])
        
        var dateString:String = "\(year.to2String())\(month.to2String())\(day.to2String())"
        if dateString.toInt() == 0 {
            dateString = "20000101"
        }
        return dateString.dateFromFormat("yyyyMMdd", locale: DateFormatter().locale)!
    }
    
    /**
     return Steps goal

     :returns: goal
     */
    func getStepsGoal()->Int {
        var stepGoal:Int = Int(NSData2Bytes(getPackets()[0])[6])
        stepGoal += Int(NSData2Bytes(getPackets()[0])[7] )<<8
        stepGoal += Int(NSData2Bytes(getPackets()[0])[8] )<<16
        stepGoal += Int(NSData2Bytes(getPackets()[0])[9] )<<24
        return stepGoal;
    }
    
    func getDistanceGoal()->Int {
        var goalDistance:Int = Int(NSData2Bytes(getPackets()[0])[10])
        goalDistance += Int(NSData2Bytes(getPackets()[0])[11])
        goalDistance += Int(NSData2Bytes(getPackets()[0])[12])
        goalDistance += Int(NSData2Bytes(getPackets()[0])[13])
        return goalDistance
    }
    
    func getCaloriesGoal()->Int{
        var goalCalories:Int = Int(NSData2Bytes(getPackets()[0])[14])
        goalCalories += Int(NSData2Bytes(getPackets()[0])[15])
        goalCalories += Int(NSData2Bytes(getPackets()[0])[16])
        goalCalories += Int(NSData2Bytes(getPackets()[0])[17])
        return goalCalories
    }
    
    /**
    return History Daily steps
    */
    func getTotalSteps()->Int {
        var totalSteps:Int = Int(NSData2Bytes(getPackets()[1])[4] )
        totalSteps += Int(NSData2Bytes(getPackets()[1])[5] )<<8
        totalSteps += Int(NSData2Bytes(getPackets()[1])[6] )<<16
        totalSteps += Int(NSData2Bytes(getPackets()[1])[7] )<<24
        return totalSteps
    }
    
    /*
     total walk steps
     */
    func getTotalWalkSteps()->Int {
        var totalWalkSteps:Int = Int(NSData2Bytes(getPackets()[1])[8] )
        totalWalkSteps += Int(NSData2Bytes(getPackets()[1])[9] )<<8
        totalWalkSteps += Int(NSData2Bytes(getPackets()[1])[10] )<<16
        totalWalkSteps += Int(NSData2Bytes(getPackets()[1])[11] )<<24
        return totalWalkSteps
    }
    
    func getTotalRunSteps()->Int {
        var totalRunSteps:Int = Int(NSData2Bytes(getPackets()[1])[12] )
        totalRunSteps += Int(NSData2Bytes(getPackets()[1])[13] )<<8
        totalRunSteps += Int(NSData2Bytes(getPackets()[1])[14] )<<16
        totalRunSteps += Int(NSData2Bytes(getPackets()[1])[15] )<<24
        return totalRunSteps
    }
    
    func getTotalDistance() -> Int {
        var totalDist:Int = Int(NSData2Bytes(getPackets()[1])[16] )
        totalDist += Int(NSData2Bytes(getPackets()[1])[17] )<<8
        totalDist += Int(NSData2Bytes(getPackets()[1])[18] )<<16
        totalDist += Int(NSData2Bytes(getPackets()[1])[19] )<<24
        return totalDist
    }
    
    func getTotalWalkDistance() -> Int {
        let packetno = 2
        let offset = 2
        var totalWalkDistance:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalWalkDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
        totalWalkDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
        totalWalkDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
        return totalWalkDistance/100
    }
    
    /**
     daily Running Distance
     
     :returns: daily Running Distance
     */
    func getTotalRunDistance()->Int {
        let packetno = 2
        let offset = 6
        var totalRunDistance:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalRunDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
        totalRunDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
        totalRunDistance += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
        return totalRunDistance/100
    }
    
    func getTotalCalories() -> Int {
        let packetno = 2
        let offset = 10
        var totalCalories:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalCalories += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
        totalCalories += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
        totalCalories += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
        return totalCalories/1000
    }
    
    func getTotalRunTime() -> Int {
        let packetno = 2
        let offset = 14
        var totalRunTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalRunTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
        totalRunTime += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
        totalRunTime += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
        return totalRunTime/60
    }
    
    func getTotalWalkTime() -> Int {
        let packetno = 2
        let offset = 18
        var totalWalkTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalWalkTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
        totalWalkTime += Int(NSData2Bytes(getPackets()[packetno+1])[2])
        totalWalkTime += Int(NSData2Bytes(getPackets()[packetno+1])[3])<<8
        return totalWalkTime/60
    }
    
    /**
     get inactivity time, minute
     */
    func getInactivityTime() ->Int {
        let packetno = 3
        let offset = 4
        var value:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        value =  value + Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        value =  value + Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<16
        value =  value + Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<24
        return value
    }
    
    /**
     *
     * @return the harvesting of solar per day, unit is in minutes
     */
    func getTotalSolarHarvestingTime() ->Int  {
        let packetno = 3
        let offset = 8
        
        var harvestingTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        harvestingTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        harvestingTime += Int(NSData2Bytes(getPackets()[packetno])[offset+2] )<<8
        harvestingTime += Int(NSData2Bytes(getPackets()[packetno])[offset+3] )<<8
        return harvestingTime/60
    }
    
    /**
     *@return total sleep time, minute
     */
    func getTotalSleepTime() -> Int {
        let packetno = 3
        let offset = 12

        var totalSleep:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalSleep += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        return totalSleep
    }
    
    /**
     *@return total wake sleep time, minute
     */
    func getTotalWakeTime() -> Int {
        let packetno = 3
        let offset = 14
        
        var totalWakeTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalWakeTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        return totalWakeTime
    }
    
    /**
     *@return total light sleep time, minute
     */
    func getTotalLightTime() -> Int {
        let packetno = 3
        let offset = 16
        
        var totalLightTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalLightTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        return totalLightTime
    }
    
    /**
     *@return total deep sleep time, minute
     */
    func getTotalDeepTime() -> Int {
        let packetno = 3
        let offset = 18
        
        var totalDeepTime:Int = Int(NSData2Bytes(getPackets()[packetno])[offset] )
        totalDeepTime += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
        return totalDeepTime
    }
    
    /**
     *
     * @return  the hourly walkDis
     */
    func getHourlyWalkDist() -> [Int] {
        var HourlyWalkDist:[Int] = [];
        var hourlyWalkDistValue:Int = 0;
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 2;
            hourlyWalkDistValue = 0;
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+2] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+3] != 0xFF{
                hourlyWalkDistValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyWalkDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
                hourlyWalkDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
                hourlyWalkDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
            }
            HourlyWalkDist.append(hourlyWalkDistValue/100)
        }
        return HourlyWalkDist;
    }
    
    /**
     *
     * @return  the hourly run dist
     */
    func getHourlyRunDist() -> [Int] {
        var HourlyRunDist:[Int] = [];
        var hourlyRunDistValue = 0;
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 6;
            hourlyRunDistValue = 0;
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+2] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+3] != 0xFF{
                hourlyRunDistValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyRunDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
                hourlyRunDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
                hourlyRunDistValue += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
            }
            HourlyRunDist.append(hourlyRunDistValue/100)
        }
        return HourlyRunDist;
    }
    
    /**
     *
     * @return  the hourly run dist
     */
    func getHourlyCalories() -> [Int] {
        var HourlyCalories:[Int] = [];
        var hourlyCaloriesValue:Int = 0;
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 10;
            hourlyCaloriesValue = 0;
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+2] != 0xFF && NSData2Bytes(getPackets()[packetno])[offset+3] != 0xFF{
                hourlyCaloriesValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyCaloriesValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
                hourlyCaloriesValue += Int(NSData2Bytes(getPackets()[packetno])[offset+2])<<16
                hourlyCaloriesValue += Int(NSData2Bytes(getPackets()[packetno])[offset+3])<<24
            }
            HourlyCalories.append(hourlyCaloriesValue/100)
        }
        return HourlyCalories;
    }
    
    /**
     *@return hourly walk steps
     */
    func getHourlyWalkSteps() ->[Int] {
        var hourlyStepsArray:[Int] = []
        var hourlySteps:Int = 0
        
        //get every hour Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 14;
            hourlySteps = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF {
                hourlySteps = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlySteps += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
            }
            hourlyStepsArray.append(hourlySteps)
        }
        return hourlyStepsArray
    }

    /**
     *@return Hourly Run steps
     */
    func getHourlyRunSteps() ->[Int] {
        var hourlyRunStepsArray:[Int] = []
        var hourlyRunSteps:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 16;
            hourlyRunSteps = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF {
                hourlyRunSteps = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyRunSteps += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
            }
            hourlyRunStepsArray.append(hourlyRunSteps)
        }
        return hourlyRunStepsArray
    }
    
    /**
     *@return Hourly walk time
     */
    func getHourlyWalkTime() ->[Int] {
        var hourlyWalkTimeArray:[Int] = []
        var hourlyWalkTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER;
            let offset = 18;
            hourlyWalkTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF {
                hourlyWalkTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyWalkTimeValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
            }
            hourlyWalkTimeArray.append(hourlyWalkTimeValue)
        }
        return hourlyWalkTimeArray
    }
    
    /**
     *@return Hourly run time
     */
    func getHourlyRunTime() ->[Int] {
        var hourlyRunTimeArray:[Int] = []
        var hourlyRunTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 2;
            hourlyRunTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF {
                hourlyRunTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
                hourlyRunTimeValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1])<<8
            }
            hourlyRunTimeArray.append(hourlyRunTimeValue)
        }
        return hourlyRunTimeArray
    }
    
    /**
     *
     * @return  the harvesting of solar per hour, unit is in minutes
     */
    func getHourlyHarvestTime() ->[Int] {
        var HourlyHarvestTime:[Int] = [];
        var hourlyHarvestTimeValue:Int = 0;
        //get every hour swim time:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 4;
            hourlyHarvestTimeValue = 0;
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF
                && NSData2Bytes(getPackets()[packetno])[offset+1] != 0xFF{
                hourlyHarvestTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset] )
                hourlyHarvestTimeValue += Int(NSData2Bytes(getPackets()[packetno])[offset+1] )<<8
            }
            HourlyHarvestTime.append(hourlyHarvestTimeValue/60)
        }
        return HourlyHarvestTime;
    }
    
    /**
     *@return Hourly sleep time
     */
    func getHourlySleepTime() ->[Int] {
        var hourlySleepTimeArray:[Int] = []
        var hourlySleepTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 6;
            hourlySleepTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF {
                hourlySleepTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
            }
            hourlySleepTimeArray.append(hourlySleepTimeValue)
        }
        return hourlySleepTimeArray
    }
    
    /**
     *@return Hourly weak sleep time
     */
    func getHourlyWakeSleepTime() ->[Int] {
        var hourlyWeakSleepTimeArray:[Int] = []
        var hourlyWeakSleepTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 7;
            hourlyWeakSleepTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF {
                hourlyWeakSleepTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
            }
            hourlyWeakSleepTimeArray.append(hourlyWeakSleepTimeValue)
        }
        return hourlyWeakSleepTimeArray
    }
    
    /**
     *@return Hourly light sleep time
     */
    func getHourlyLightSleepTime() ->[Int] {
        var hourlyLightSleepTimeArray:[Int] = []
        var hourlyLightSleepTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 8;
            hourlyLightSleepTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF {
                hourlyLightSleepTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
            }
            hourlyLightSleepTimeArray.append(hourlyLightSleepTimeValue)
        }
        return hourlyLightSleepTimeArray
    }
    
    /**
     *@return Hourly light sleep time
     */
    func getHourlyDeepSleepTime() ->[Int] {
        var hourlyDeepSleepTimeArray:[Int] = []
        var hourlyDeepSleepTimeValue:Int = 0
        //get every hour run Steps:
        for index:Int in 0..<24 {
            let packetno = HEADERLENGTH+index*HOURLYPACKETSNUMBER+1;
            let offset = 9;
            hourlyDeepSleepTimeValue = 0
            if NSData2Bytes(getPackets()[packetno])[offset] != 0xFF {
                hourlyDeepSleepTimeValue = Int(NSData2Bytes(getPackets()[packetno])[offset])
            }
            hourlyDeepSleepTimeArray.append(hourlyDeepSleepTimeValue)
        }
        return hourlyDeepSleepTimeArray
    }

}
