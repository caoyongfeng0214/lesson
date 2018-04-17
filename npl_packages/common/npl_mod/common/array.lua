--[[
Author: CYF
Date: 2018年1月1日
Desc: 数组处理的常用方法
]]



--[[
    取得数组中元素的数量
]]
table.length = function(ary)
    return #ary;
end


--[[
    往数组的最后位置新增一个元素
]]
table.push = function(ary, item)
    ary[#ary + 1] = item;
end


--[[
    遍历数组中的每一个元素，执行指定的function
    参数 fn 将接收到两个参数，一个是遍历到的某个元素，另一个是当前的索引
]]
table.forEach = function(ary, fn)
    local i = nil;
    for i = 1, #ary do
        fn(ary[i], i);
    end
end



--[[
    遍历数组中的每一个元素，执行指定的function后的返回值组成新的数组，并返回
    参数 fn 将接收到两个参数，一个是遍历到的某个元素，另一个是当前的索引
]]
table.map = function(ary, fn)
    local ary2 = {};
    table.forEach(ary, function(T, idx)
        table.push(ary2, fn(T, idx));
    end);
    return ary2;
end


--[[
    过滤
]]
table.filter = function(ary, fn)
    local ary2 = {};
    table.forEach(ary, function(T, idx)
        if(fn(T, idx)) then
            table.push(ary2, T);
        end
    end);
    return ary2;
end



NPL.export(table);