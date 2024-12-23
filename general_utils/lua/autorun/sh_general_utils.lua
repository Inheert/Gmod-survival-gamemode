AddCSLuaFile()

function util.DeepCopy(orig, exclude_keys, seen)
	exclude_keys = exclude_keys or {}
	seen = seen or {} 

	if seen[orig] then
		return seen[orig]
	end

	local orig_type = type(orig)
	local copy

	if orig_type == 'table' then
		copy = {}
		seen[orig] = copy

		for orig_key, orig_value in next, orig, nil do
			if not exclude_keys[orig_key] then
				copy[util.DeepCopy(orig_key, exclude_keys, seen)] = util.DeepCopy(orig_value, exclude_keys, seen)
			end
		end
		local orig_metatable = getmetatable(orig)
		if orig_metatable and type(orig_metatable) == "table" then
			setmetatable(copy, util.DeepCopy(orig_metatable, exclude_keys, seen))
		end
	else -- number, string, boolean, etc.
		copy = orig
	end

	return copy
end
