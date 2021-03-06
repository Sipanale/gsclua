--Edit parameters in this section
local desired_species = -1 -- the desired pokemon dex number / -1 for all species/encounter slots
--End of parameters

local atkdef
local spespc
local species

local enemy_addr
local version = memory.readword(0x14e)
if version == 0xae0d or version == 0x2d68 then
    print("USA Gold/Silver detected")
    enemy_addr = 0xd0f5
elseif version == 0x6084 or version == 0x341d then
    print("Japanese Gold/Silver detected")
    enemy_addr = 0xd0e7
elseif version == 0xd218 or version == 0xe2f2 then
    print("USA/Europe Crystal detected")
    enemy_addr = 0xd20c
elseif version == 0x409a then
    print("Japanese Crystal detected")
    enemy_addr = 0xd23d
else
    print(string.format("Unknown version, code: %4x", version))
    print("Script stopped")
    return
end

local fish_flag_addr = enemy_addr - 0x1d
local species_addr = enemy_addr - 0x8
local dv_flag_addr = enemy_addr + 0x21
local battle_flag_addr = enemy_addr + 0x22
 
function shiny(atkdef,spespc)
    if spespc == 0xAA then
        if atkdef == 0x2A or atkdef == 0x3A or atkdef == 0x6A or atkdef == 0x7A or atkdef == 0xAA or atkdef == 0xBA or atkdef == 0xEA or atkdef == 0xFA then
            return true
        end
    end
    return false
end

local state = savestate.create()
while true do
    savestate.save(state)
    joypad.set(1, {A=true})
    emu.frameadvance()
    if memory.readbyte(fish_flag_addr) ~= 0x01 then             --fished flag
        print("Nothing bited")
        savestate.load(state)
    else
        for i = 1, 300 do
            emu.frameadvance()
        end
        joypad.set(1, {A=true})
        while memory.readbyte(battle_flag_addr) == 0 do         --battle start flag
            emu.frameadvance()
        end
        species = memory.readbyte(species_addr)
        print(string.format("Species: %d", species))

        if desired_species > 0 and desired_species ~= species then
            savestate.load(state)
        else
            while memory.readbyte(dv_flag_addr) ~= 0x01 do      --dvs generated flag
                emu.frameadvance()
            end
            atkdef = memory.readbyte(enemy_addr)
            spespc = memory.readbyte(enemy_addr + 1)
            print(string.format("Atk: %d Def: %d Spe: %d Spc: %d", math.floor(atkdef/16), atkdef%16, math.floor(spespc/16), spespc%16))

            if shiny(atkdef, spespc) then
                print("Shiny found!!")
                return
            else
                savestate.load(state)
            end
        end
    end
    emu.frameadvance()
end