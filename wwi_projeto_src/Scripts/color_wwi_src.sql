select 

    wrc.ColorID,
    wrc.ColorName

from Warehouse.Colors as wrc 

    left join

    Warehouse.Colors_Archive as wrca
on wrc.ColorID = wrca.ColorID;