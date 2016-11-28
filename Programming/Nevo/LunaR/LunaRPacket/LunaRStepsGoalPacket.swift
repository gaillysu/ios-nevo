import UIKit

class LunaRStepsGoalPacket: LunaRPacket {
    
    /**
    return the Current Daily steps
    */
    func getDailySteps() ->Int
    {
        var dailySteps:Int = Int(NSData2Bytes(getPackets()[0])[2] )
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[3] )<<8
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[4] )<<16
        dailySteps =  dailySteps + Int(NSData2Bytes(getPackets()[0])[5] )<<24
        return dailySteps
    }
    /**
    return the Daily steps Goal
    */
    func getDailyStepsGoal() ->Int
    {
        var dailyStepGoal:Int = Int(NSData2Bytes(getPackets()[0])[6] )
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[7] )<<8
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[8] )<<16
        dailyStepGoal =  dailyStepGoal + Int(NSData2Bytes(getPackets()[0])[9] )<<24
        return dailyStepGoal
    }

    
    /**
     get Packet data timer
     
     :returns: timer/Year,Month,Day
     */
    func getDateTimer()->Date{
        var year:Int = Int(NSData2Bytes(getPackets()[0])[10] )
        year = year + Int(NSData2Bytes(getPackets()[0])[11] )<<8
        let month:Int = Int(NSData2Bytes(getPackets()[0])[12])
        let day:Int = Int(NSData2Bytes(getPackets()[0])[13])
        let hour:Int = Int(NSData2Bytes(getPackets()[0])[14])
        let minute:Int = Int(NSData2Bytes(getPackets()[0])[15])
        let seconds:Int = Int(NSData2Bytes(getPackets()[0])[16])
        let dateString:String = "\(year.to2String())\(month.to2String())\(day.to2String()) \(hour.to2String()):\(minute.to2String()):\(seconds.to2String())"
        let date = dateString.dateFromFormat("yyyyMMdd HH:mm:ss", locale: DateFormatter().locale)!
        return date
    }
}
