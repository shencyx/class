local Class = require 'class'

Point = Class("Point")
Point.scale = 2

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:getScaled()
    return self.x * Point.scale, self.y * Point.scale
  end

function Point:__tostring()
    return self.x .. ", " .. self.y
end

local p = Point(10, 20)
print("getScaled:", p:getScaled())
print("tostring:", p)
print("name:", p:class_name())


Rect = Class("Rect", "Point")

function Rect:new(x, y, width, height)
  Rect.super.new(self, x, y)
  self.width = width or 0
  self.height = height or 0
end

function Rect:__tostring()
    return self.x .. ", " .. self.y .. "," .. self.width .. "," .. self.height
end

local r = Rect(10, 20, 30, 40)
print("getScaled:", r:getScaled())
print("tostring:", r)
print("name:", r:class_name())


print("============================")

collectgarbage("stop")
for i = 1, 100, 1 do
    local t = Point(i, i)
end

print("obj_new_cnt:", Class.obj_new_cnt("Point"), Class.obj_exist_cnt("Point"))
collectgarbage("collect")

print("collect obj_new_cnt:", Class.obj_new_cnt("Point"), Class.obj_exist_cnt("Point"))
