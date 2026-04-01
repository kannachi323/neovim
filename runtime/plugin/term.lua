local M = {}

function M.term_save()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= 'terminal' then
        vim.notify("cannot save terminal: buftype is not terminal")
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local dir = vim.fn.stdpath('state') ..  '/term'
    vim.fn.mkdir(dir, 'p')

    local data = vim.mpack.encode({ lines = lines })

    local filename = dir .. '/' .. tostring(buf) .. '.msgpack'
    local outfile = io.open(filename, 'wb')
    if outfile == nil then
      return
    end
    outfile:write(data)
    outfile:close()

    vim.notify('file saved to ' .. filename)
end

function M.term_load(term_name)
    local infile = io.open(vim.fn.expand(term_name), 'rb')
    if not infile then
        vim.notify("cannot open term_session")
        return
    end
    local raw_data = infile:read('*a')
    infile:close()

    --[[ This is where we will use cells_to_ansi() to parse
         cells with attribute data ]]

    local data = vim.mpack.decode(raw_data)

    local buf = vim.api.nvim_create_buf(true, true)
    local term = vim.api.nvim_open_term(buf, {})

    vim.api.nvim_set_current_buf(buf)

    for _, line in ipairs(data.lines) do
        vim.api.nvim_chan_send(term, line .. '\n')
    end

    vim.notify('terminal restored from ' .. term_name)
end

return M
