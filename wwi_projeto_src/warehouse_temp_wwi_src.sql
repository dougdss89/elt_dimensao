select 

    crta.ColdRoomTemperatureID,
    crta.ColdRoomSensorNumber,
    crta.RecordedWhen,
    crta.Temperature,
    crta.ValidFrom,
    crta.ValidFrom

from Warehouse.ColdRoomTemperatures as crt

right join

    Warehouse.ColdRoomTemperatures_Archive as crta

on crt.ColdRoomTemperatureID = crta.ColdRoomTemperatureID;