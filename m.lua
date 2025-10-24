
for _,v in next, getreg() do
if type(v) == "thread" then
if string.find(debug.traceback(v),"<",1,true) then
coroutine.close(v)
print("ok")
end
end
end

for i,v in next, getallthreads() do
local s = getscriptfromthread(v)
if string.find(tostring(s), "<",1,true) then
print("k")
end
end
