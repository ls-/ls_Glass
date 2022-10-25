local Core = unpack(select(2, ...))
local TP = Core:GetModule("TextProcessing")

-- luacheck: push ignore 113
local strjoin = strjoin
local strsplit = strsplit
-- luacheck: pop

---
--Takes a texture escape string and adjusts its yOffset
local function adjustTextureYOffset(texture)
  -- Texture has 14 parts
  -- path, height, width, offsetX, offsetY,
  -- texWidth, texHeight
  -- leftTex, topTex, rightTex, bottomText,
  -- rColor, gColor, bColor

  -- Strip escape characters
  -- Split into parts
  local parts = {strsplit(':', strsub(texture, 3, -3))}
  local yOffset = Core.db.profile.iconTextureYOffset

  if #parts < 5 then
    -- Pad out ommitted attributes
    for i=1, 5 do
      if parts[i] == nil then
        if i == 3 then
          -- If width is not specified, the width should equal the height
          parts[i] = parts[2]
        else
          parts[i] = '0'
        end
      end
    end
  end

  -- Adjust yOffset by configured amount
  parts[5] = tostring(tonumber(parts[5]) - yOffset)

  -- Rejoin string and readd escape codes
  return '|T'..strjoin(':', unpack(parts))..'|t'
end


---
-- Gets all inline textures found in the string and adjusts their yOffset
local function textureProcessor(text)
  local cursor = 1
  local origLen = strlen(text)

  local parts = {}

  while cursor <= origLen do
    local mStart, mEnd = strfind(text, '%|T.-%|t', cursor)

    if mStart then
      table.insert(parts, strsub(text, cursor, mStart - 1))
      table.insert(parts, adjustTextureYOffset(strsub(text, mStart, mEnd)))
      cursor = mEnd + 1
    else
      -- No more matches
      table.insert(parts, strsub(text, cursor, origLen))
      cursor = origLen + 1
    end
  end

  return strjoin("", unpack(parts))
end

---
-- Adds Prat Timestamps if configured
local function pratTimestampProcessor(text)
  return _G.Prat.Addon:GetModule("Timestamps"):InsertTimeStamp(text)
end

---
-- Text processing pipeline
local TEXT_PROCESSORS = {
  textureProcessor,
  pratTimestampProcessor
}

function TP:ProcessText(text)
  local result = text

  for _, processor in ipairs(TEXT_PROCESSORS) do
    -- Prevent failing processors from bringing down the whole pipeline
    local retOk, retVal = pcall(processor, result)

    if retOk then
      result = retVal
    end
  end

  return result
end
