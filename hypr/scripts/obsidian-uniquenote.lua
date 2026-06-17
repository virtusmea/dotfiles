#!/usr/bin/env lua

-- ==================== KONFIGURATION ====================
local VAULT_NAME = "LinuxLernen"
local PLUGIN_CONFIG_PATH = "/home/xocx/Dokumente/LinuxLernen/.obsidian/plugins/obsidian-focus-mode/data.json"

-- Die exakten Command-IDs aus Obsidian
local CMD_UNIQUE_NOTE = "zk-prefixer"
local CMD_TOGGLE_SUPER_FOCUS = "obsidian-focus-mode:toggle-super-focus-mode"
-- =======================================================

-- Hilfsfunktion, um Terminal-Ausgaben in Lua einzulesen
local function sys_call(command)
    local handle = io.popen(command)
    if not handle then return "" end
    local result = handle:read("*a")
    handle:close()
    return result
end

-- Funktion prüft, welchen Zustand die data.json hat
local function get_focus_mode_status()
    local f = io.open(PLUGIN_CONFIG_PATH, "r")
    if not f then return false, false end
    local content = f:read("*a")
    f:close()
    
    local is_focus_active = string.find(content, '"focusModeActive":%s*true') ~= nil
    local is_super_active = string.find(content, '"superFocusModeActive":%s*true') ~= nil
    
    return is_focus_active, is_super_active
end

-- 1. Zustand von Obsidian aus Hyprland abfragen
local active_window_raw = sys_call("hyprctl activewindow")

-- Prüfen, ob Obsidian das aktive Fenster ist und im Floating-Modus läuft
local is_obsidian = string.find(active_window_raw, "class: obsidian") ~= nil
local is_floating = string.find(active_window_raw, "floating: 1") ~= nil
local is_obsidian_active = is_obsidian and is_floating

-- Status aus JSON holen
local focus_active, super_active = get_focus_mode_status()

-- 2. Logik-Weiche
if is_obsidian_active then
    -- ==========================================
    -- FALL A: Das schwebende Fenster ist offen -> Modus aus, dann Scratchpad schließen
    -- ==========================================
    
    -- Wenn irgendein Fokusmodus an ist, schalten wir ihn aus (Super-Focus nutzt denselben Toggle zum Beenden)
    if focus_active or super_active then
        os.execute("xdg-open 'obsidian://advanced-uri?vault=" .. VAULT_NAME .. "&commandid=" .. CMD_TOGGLE_SUPER_FOCUS .. "'")
        -- Kurz warten, damit Obsidian das Layout zurücksetzt, bevor das Fenster ausgeblendet wird
        os.execute("sleep 0.05")
    end

    -- Scratchpad schließen (Fenster verschwinden lassen)
    os.execute("hyprctl dispatch togglespecialworkspace obsidian")

else
    -- ==========================================
    -- FALL B: Zettelkasten-Note im verkleinerten Super-Fokus-Modus öffnen
    -- ==========================================
    
    -- 1. Sicherstellen, dass der Scratchpad-Workspace sichtbar ist
    os.execute("hyprctl dispatch togglespecialworkspace obsidian")
    
    -- 2. Fenster als Floating erzwingen und Größe/Position anpassen
    os.execute("hyprctl dispatch setfloating class:obsidian")
    os.execute("hyprctl dispatch resizewindowpixel exact 60% 70%,class:obsidian")
    os.execute("hyprctl dispatch centerwindow")
    
    -- 3. Logik für den Super-Fokusmodus & die Unique Note
    if not super_active then
        -- Falls Super-Fokus AUS: Erst Super-Fokus AN, kurz warten, dann Unique Note aufrufen
        os.execute("xdg-open 'obsidian://advanced-uri?vault=" .. VAULT_NAME .. "&commandid=" .. CMD_TOGGLE_SUPER_FOCUS .. "'")
        os.execute("sleep 0.1") -- 100ms Pause
        os.execute("xdg-open 'obsidian://advanced-uri?vault=" .. VAULT_NAME .. "&commandid=" .. CMD_UNIQUE_NOTE .. "'")
    else
        -- Falls Super-Fokus bereits AN: Direkt die Unique Note öffnen
        os.execute("xdg-open 'obsidian://advanced-uri?vault=" .. VAULT_NAME .. "&commandid=" .. CMD_UNIQUE_NOTE .. "'")
    end
end
