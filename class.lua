--
-- class
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--


local classes = {}
local obj_new_cnt = {}    -- 只记录new过的数量，回收的没有扣回
local obj_list = {}


local function get_obj_list(name)
  local list = obj_list[name]
  if not list then
    list = setmetatable({}, {__mode = "kv"})
    obj_list[name] = list
  end
  return list
end

local Class = {}
Class.__index = Class
Class.__name = "basic"


function Class:new(...)
end


function Class:extend(name)
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.__name = name
  cls.super = self
  setmetatable(cls, self)
  return cls
end


function Class:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Class:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


function Class:__tostring()
  return "Class:".. self.__name
end

function Class:class_name()
  return self.__name
end

function Class:__call(...)
  local obj = setmetatable({}, self)
  local name = self.__name
  obj_new_cnt[name] = 1 + (obj_new_cnt[name] or 0)
  obj:new(...)
  local list = get_obj_list(name)
  list[obj] = true
  return obj
end


local M = setmetatable({}, {__call = function(_, name, parentname)
  assert(not classes[name], string.format('class <%s> already exists', name))
  local cls
  if parentname then
    cls = classes[parentname]
    assert(cls, string.format('class <%s> not exists', parentname))
  else
    cls = Class
  end

  local clsobj = cls:extend(name)
  classes[name] = clsobj
  return clsobj
end})

function M.obj_new_cnt(name)
  if name then
    return obj_new_cnt[name]
  end
  return obj_new_cnt
end

-- 可能存在未GC的obj，可以先全量GC下
function M.obj_exist_cnt(name)
  if name then
    local list = get_obj_list(name)
    local cnt = 0
    for _ in pairs(list) do
      cnt = cnt + 1
    end
    return cnt
  end

  local ret = {}
  for k, v in pairs(obj_list) do
    local cnt = 0
    for _ in pairs(v) do
      cnt = cnt + 1
    end
    ret[k] = cnt
  end
  return ret
end

return M
