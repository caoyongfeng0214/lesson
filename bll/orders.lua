local db = NPL.load('../dal/dbutil')

local orders = {}

local tbl = 'orders'

orders.save = function( order, cn )
    return db.insert(tbl, order, cn)
end

orders.update = function( order, cn )
    return db.updateBySn(tbl, order, cn)
end

NPL.export(orders)
