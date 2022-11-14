-- Contributors: cacahuete_uchi@Curse

local _, ns = ...
local L = ns.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

L["BACKGROUND_ALPHA"] = "Opacidad Del Fondo"
L["CHANGELOG"] = "Registro De Cambios"
L["CHANGELOG_FULL"] = "Entero"
L["CONFIG_WARNING"] = "Recomiendo encarecidamente |cffffd200/actualizar|r la interfaz despues de haber configurado el addon o incluso tras haber abierto este panel para así evitar cualquier error durante un combate"
L["DOCK_AND_EDITBOX"] = "Pestañas y Cuadro de Edición"
L["DOWNLOADS"] = "Descargas."
L["FADE_IN_DURATION"] = "Duración Del Desvanecimiento De Entrada"
L["FADE_OUT_DELAY"] = "Retraso Del Desvanecimiento De Salida"
L["FADE_OUT_DURATION"] = "Duración Del Desvanecimiento De Salida"
L["FADING"] = "Desvanecimiento"
L["FONT"] = "Fuente"
L["FONT_EDITBOX"] = "Caja De Edición De Fuente"
L["MESSAGES"] = "Mensajes"
L["MOUSEOVER_TOOLTIPS"] = "Texto Emergente Al Pasar El Ratón Por Encima"
L["OPEN_CONFIG"] = "Abrir configuración"
L["OUTLINE"] = "Contorno"
L["PERSISTENT"] = "Persistente"
L["SHADOW"] = "Sombra"
L["SIZE"] = "Tamaño"
L["SUPPORT"] = "Soporte"
L["X_PADDING"] = "Espaciado Horizontal"
L["Y_PADDING"] = "Espaciado Vertical"
