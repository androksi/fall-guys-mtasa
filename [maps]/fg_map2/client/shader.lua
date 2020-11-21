local texture = dxCreateTexture("assets/images/lava.jpg")
local raw = [[
    texture tex;
	technique replace {
		pass P0 {
			Texture[0] = tex;
		}
	}
]]

local shader = dxCreateShader(raw)

if shader then
    dxSetShaderValue(shader, "tex", texture)
    engineApplyShaderToWorldTexture(shader, "waterclear256")
end