import Foundation

/*
Represents a series of packets concatenated together to form the response from the watch
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class LunaRPacket {
    fileprivate var mPackets:[Data]=[]
    fileprivate var mHeader:UInt8 = 0
    let endFlag:UInt8 = 0xFF
    
    struct TotalHistory
    {
        var TotalSteps:Int = 0;
        var HourlySteps:[Int] = [];
        //add new from v1.2.2
        //unit:cm->meter
        var TotalDist:Int = 0;
        var HourlyDist:[Int] = [];
        //unit: cal->kcal
        var TotalCalories:Int = 0;
        var HourlyCalories:[Int] = [0];
        var InactivityTime:Int = 0;
        var TotalInZoneTime:Int = 0;
        var TotalOutZoneTime:Int = 0;
        //unit: minute
        var TotalSleepTime:Int = 0;
        var HourlySleepTime:[Int] = [];
        var TotalWakeTime:Int = 0;
        var HourlyWakeTime:[Int] = [];
        var TotalLightTime:Int = 0;
        var HourlyLightTime:[Int] = [];
        var TotalDeepTime:Int = 0;
        var HourlyDeepTime:[Int] = [];
        //end add new
        var Date:Foundation.Date;
        init( date:Foundation.Date)
        {
           Date = date
        }
    }
    
    init(packets:[Data]) {
        if(packets.count >= 2){
            mPackets = packets
            mHeader = NSData2Bytes(mPackets[0])[1]
        }
    }
    
    func getHeader() ->UInt8 {
        return mHeader
    }
    
    func getPackets() ->[Data] {
        return mPackets
    }
    
    func copy()->LunaRStepsGoalPacket {
        return LunaRStepsGoalPacket(packets: mPackets)
    }
    
    func copy()->LunaRDailyTrackerInfoPacket {
        return LunaRDailyTrackerInfoPacket(packets: mPackets)
    }
    
    func copy()->LunaRDailyTrackerPacket {
        return LunaRDailyTrackerPacket(packets: mPackets)
    }
    
    func copy()->LunaRWatchNamePacket {
        return LunaRWatchNamePacket(packets: mPackets)
    }
    
    func copy()->ReceiveNewNotificationPacket {
        return ReceiveNewNotificationPacket(packets: mPackets)
    }
    
    func copy() -> GetotalAppIDPacket {
        return GetotalAppIDPacket(packets: mPackets)
    }
    
    func copy() -> DeleteAllAppIDPacket {
        return DeleteAllAppIDPacket(packets: mPackets)
    }
    
    func copy() -> GetNotificationAppIDPacket {
        return GetNotificationAppIDPacket(packets: mPackets)
    }
    
    func isVaildPacket() ->Bool {
        if (mPackets.count < 2) {
           return false
        }
        
        for i:Int in 0..<mPackets.count-1 {
            if UInt8(i) != NSData2Bytes(mPackets[i])[0]{
                return false
            }
        }
        return true
    }
}
