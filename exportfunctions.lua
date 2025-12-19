-- save_methods.lua
-- 将 peripherals.getMethods("back") 的结果写入文件 back_methods.txt
local side = "back"
local outFile = "back_methods.txt"

-- 支持两种常见 API 名称：peripherals（用户输入可能写错）或 peripheral（官方 API）
local api = _G.peripherals or _G.peripheral
if not api then
  error("找不到 peripheral/peripherals API。确认你在 CC:Tweaked/ComputerCraft 环境中运行。")
end

-- 安全调用，捕获可能的运行时错误
local ok, methodsOrErr = pcall(function() return api.getMethods(side) end)
if not ok then
  print("调用 getMethods 时出错：", tostring(methodsOrErr))
  return
end

local methods = methodsOrErr
if not methods then
  print(("在侧面 '%s' 未找到外设或无方法可列。"):format(side))
  return
end

-- 打开文件准备写入
local fh, ferr = fs.open(outFile, "w")
if not fh then
  print("无法打开输出文件：", tostring(ferr))
  return
end

-- 将 methods 表规范化为字符串数组 —— 处理 methods 可能是数组或 { name = true } 形式
local list = {}
for k, v in pairs(methods) do
  if type(k) == "number" then
    -- 可能是数值索引数组：方法名在 v
    list[#list + 1] = tostring(v)
  else
    -- 可能是 { methodName = true } 的形式，或者 methodName -> meta
    if v == true then
      list[#list + 1] = tostring(k)
    else
      list[#list + 1] = tostring(k) .. " : " .. textutils.serialize(v)
    end
  end
end

-- 按字母排序，写入每行一个方法名（更好读）
table.sort(list)
for _, line in ipairs(list) do
  fh.writeLine(line)
end
fh.close()

print(("已将 %d 个方法写入文件 %s"):format(#list, outFile))
