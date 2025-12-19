-- Este archivo debe ir dentro de tu carpeta de configuración de nvim
-- Ruta usual: ~/.config/nvim/lua/utils.lua

local M = {}

-- Función para clonar y extender tablas (shallow copy)
-- Uso: local new_obj = utils.spread(original, { extra = 1 })
function M.spread(base, extension)
    local new_table = {}

    -- 1. Copiamos las propiedades del objeto base
    if base then
        for key, value in pairs(base) do
            new_table[key] = value
        end
    end

    -- 2. Sobrescribimos o agregamos las propiedades de la extensión
    if extension then
        for key, value in pairs(extension) do
            new_table[key] = value
        end
    end

    return new_table
end

function M.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Retornamos la tabla M para que sea accesible al hacer require('utils')
return M
