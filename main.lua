--- Run `:checkhealth` and track the severity of thei issue(s) found.

local _Code = {
    ["10"] = 10,
    ["20"] = 20,
    ["30"] = 30,
    ["error"] = 30,
    info = 10,
    warn = 20,
}

--- Temporarily track calls to `vim.health.*`
---
---@param caller fun(): nil The main function that, we assume, calls `vim.cmd.checkhealth` as part of its work.
---@return integer # A 0-or-more value. 0 == success. 1+ == some issue occurred.
---
local function _bind_vim_health(caller)
    local severity = 0
    local original_error = vim.health.error

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.health.error = function(...)
        severity = math.max(severity, _Code.error)

        return original_error(...)
    end

    local original_info = vim.health.info

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.health.info = function(...)
        severity = math.max(severity, _Code.info)

        return original_info(...)
    end

    local original_warn = vim.health.warn

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.health.warn = function(...)
        severity = math.max(severity, _Code.warn)

        return original_warn(...)
    end

    caller()

    vim.health.error = original_error
    vim.health.info = original_info
    vim.health.warn = original_warn

    return severity
end

---@return string # All user-provided list of checks to run. An empty string runs "all".
local function _get_checks()
    return arg[1] or ""
end

---@return integer? # The user-provided grade of issue before we consider a problem.
local function _get_minimum_severity()
    local minimum_severity_text = arg[2]

    if minimum_severity_text then
        if not _Code[minimum_severity_text] then
            error(
                string.format(
                    'Severity not found. Got "%s", expected one of "%s" options.',
                    minimum_severity_text,
                    vim.inspect(vim.tbl_keys(_Code))
                ),
                0
            )
        end
    else
        minimum_severity_text = "error"
        print(string.format('No severity level was given. Defaulting to "%s".', minimum_severity_text))
    end

    return _Code[minimum_severity_text]
end

--- Run `:checkhealth`, print its contents to the terminal, then exit with an exit code.
local function main()
    local checks = _get_checks()

    local severity = _bind_vim_health(function()
        vim.cmd.checkhealth(checks)

        -- NOTE: Print the output of :checkhealth (the current buffer), to the terminal
        print(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
    end)

    local minimum = _get_minimum_severity()
    local exit_code = 0

    if not minimum or severity >= minimum then
        exit_code = severity
        print(string.format('Found error "%s" using code "%s".', _Code[tostring(exit_code)], exit_code))
    end

    vim.cmd(string.format("cquit %s", exit_code))
end

main()
