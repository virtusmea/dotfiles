#!/usr/bin/env lua

-- ==================== KONFIGURATION ====================
local VAULT_NAME = "LinuxLernen"
local PLUGIN_CONFIG_PATH = "/home/xocx/Dokumente/LinuxLernen/.obsidian/plugins/obsidian-focus-mode/data.json"
-- =======================================================

local function is_focus_mode_active()
    local f = io.open(PLUGIN_CONFIG_PATH, "r")
    if not f then return false end
    local content = f:read("*a")
    f:close()
    -- Wir prüfen, ob im JSON echtes "true" für den Fokusmodus steht
    return string.find(content, '"focusModeActive":%s*true') ~= nil
end

-- 1. Workspace holen und sicherstellen, dass Obsidian groß (tiled) ist
os.execute("hyprctl dispatch togglespecialworkspace obsidian")
os.execute("hyprctl dispatch settiled class:obsidian")

-- 2. Logik-Weiche: Nur wenn der Fokusmodus LAUT DATEI aktiv ist, schalten wir ihn AUS
if is_focus_mode_active() then
    os.execute("xdg-open 'obsidian://advanced-uri?vault=" .. VAULT_NAME .. "&commandid=obsidian-focus-mode:toggle-focus-mode'")
end
