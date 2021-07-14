local ffi = require("ffi")
local bitop = require("bit")

local generator = ffi.load("randombytes")

ffi.cdef [[
	int randombytes(void *buff, int bytes);
]]

local M = {};

function M.randombytes(len)
	local bytes = ffi.new("uint8_t[?]", len)
	local ret = generator.randombytes(bytes, len)

	return bytes
end

function M.random(max)
	local cache = M.randombytes(4)
	local value = 0
	for i = 0, 3 do
		value = bitop.lshift(value, 8) + cache[i]
	end

	return value % max
end

function M.uuid()
	local cache = M.randombytes(16)
	local b6 = bitop.band(cache[6], 0x0F)
	local b8 = bitop.band(cache[8], 0x3F)

	-- uuid version 4
	cache[6] = bitop.bor(0x40, b6)
	cache[8] = bitop.bor(0x80, b8)

	local uuid = string.format("%02x%02x%02x%02x-", cache[0], cache[1], cache[2], cache[3])
	uuid = string.format("%s%02x%02x-", uuid, cache[4], cache[5])
	uuid = string.format("%s%02x%02x-", uuid, cache[6], cache[7])
	uuid = string.format("%s%02x%02x-", uuid, cache[8], cache[9])
	uuid = string.format("%s%02x%02x%02x%02x%02x%02x", uuid, cache[10], cache[11], cache[12], cache[13], cache[14], cache[15])

	return uuid;
end

function M.to_hexstring(bytes)
	local str = ""
	for i = 0, ffi.sizeof(bytes) - 1 do
		if i == 0 then
			str = string.format("0x%02x ", bytes[i])
		else
			str = string.format("%s0x%02x ", str, bytes[i])
		end
	end

	return str
end

function M.randomstring(len)
	local str = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local bytes = M.randombytes(len)
	local out_str = "";

	for i = 0, len - 1 do
		local pos = bytes[i] % 62
		out_str = string.format("%s%s", out_str, string.sub(str, pos, pos))
	end

	return out_str
end

return M