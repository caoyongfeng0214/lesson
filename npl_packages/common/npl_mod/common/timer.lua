NPL.load("script/ide/timer.lua");


_G.setTimeout = function(fn, milliseconds, obj)
	local timer = commonlib.Timer:new({callbackFunc = function(timer)
		fn(timer, obj);
	end});

	timer:Change(milliseconds, nil);

	return timer; -- timer.delta: 距离上次执行的时间间隔；　timer.lastTick: 最后执行时间
end;


_G.clearTimeout = function(aTimer)
	if(aTimer) then
		aTimer:Change();
	end
end;


_G.setInterval = function(fn, milliseconds, obj)
	local timer = commonlib.Timer:new({callbackFunc = function(timer)
		fn(timer, obj);
	end});

	timer:Change(milliseconds, milliseconds);

	return timer; -- timer.delta: 距离上次执行的时间间隔；　timer.lastTick: 最后执行时间
end;


_G.clearInterval = function(aTimer)
	if(aTimer) then
		aTimer:Change();
	end
end;


NPL.export(timer);