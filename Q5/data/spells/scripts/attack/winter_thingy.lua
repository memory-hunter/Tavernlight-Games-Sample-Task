local animationDelay = 180
local combat = {}

AREA_CUSTOM9 = {
	{
		{0, 1, 1, 0, 0, 0, 0, 0, 0},
		{1, 1, 0, 0, 2, 0, 0, 1, 1},
		{0, 1, 1, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 1, 1, 0, 0, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0, 0}
	},
	{
		{0, 0, 1, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 0, 0, 0, 1, 1, 0},
		{1, 1, 0, 0, 2, 0, 0, 1, 1},
		{0, 1, 1, 1, 1, 1, 1, 1, 0},
		{0, 0, 1, 1, 1, 0, 0, 0, 0}
	},
	{
		{0, 0, 1, 1, 1, 1, 1, 0, 0},
		{0, 0, 0, 0, 0, 0, 1, 1, 0},
		{1, 1, 1, 1, 2, 1, 1, 1, 1},
		{0, 0, 0, 0, 1, 1, 1, 1, 0},
		{0, 0, 1, 1, 1, 1, 1, 0, 0},
	},
	{
		{0, 0, 0, 0, 1, 0, 0, 0, 0},
		{0, 0, 1, 1, 1, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0, 0},
		{1, 1, 1, 1, 2, 1, 1, 1, 1},
		{0, 0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 1, 1, 1, 1, 0, 0}
	},
	{
		{0, 0, 1, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 1, 0, 0, 0, 0},
		{1, 1, 1, 1, 2, 1, 1, 1, 1},
		{0, 1, 1, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 1, 1, 1, 1, 0, 0}
	}
}

-- So, the animation looks like it repeats 3 time after reaching the middle "full coverage" of the rhobus like area

for k = 1, 3 do
    for i = 1, #AREA_CUSTOM9 do
        function onGetFormulaValues(player, level, magicLevel)
            local min = (level / 5) + (magicLevel * 5.5) + 25
            local max = (level / 5) + (magicLevel * 11) + 50
            return -min, -max
        end

        local combatIndex = (k - 1) * #AREA_CUSTOM9 + i
        combat[combatIndex] = Combat()
        combat[combatIndex]:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
        combat[combatIndex]:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
        combat[combatIndex]:setArea(createCombatArea(AREA_CUSTOM9[i]))
        combat[combatIndex]:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
    end
end

function executeCallback(p, i)
    if not p.creature then
        return false
    end
    if not p.creature:isPlayer() then
        return false
    end
    p.combat[i]:execute(p.creature, p.variant)
end

function onCastSpell(creature, variant)
    local p = {creature = creature, variant = variant, combat = combat}

    for i = 1, #combat do
        if i == 1 then
            combat[i]:execute(creature, variant)
        else
            addEvent(executeCallback, (animationDelay * (i - 1)), p, i)
        end
    end

    return true
end