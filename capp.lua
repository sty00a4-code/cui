local App
---@class App
---@field stack Program[]
App = {
    meta = {
        __name = "app"
    }
}
function App.new()
    return setmetatable({
        stack = {},
        call = App.call,
        exit = App.exit,
        program = App.program,
        run = App.run,
    }, App.meta)
end
---@param self App
---@param program Program
function App:call(program)
    table.insert(self.stack, program)
end
---@param self App
---@return Program?
function App:exit()
    return table.remove(self.stack)
end
---@param self App
---@return Program?
function App:program()
    return self.stack[#self.stack]
end
---@param self App
---@return Program?
function App:event(name, ...)
    local program = self:program()
    if not program then
        return
    end
    local handle = program.events[name]
    if handle then
        return handle(program, ...)
    elseif name == "terminate" then
        error "Terminated"
    end
end
---@param self App
---@param program Program
function App:run(program)
    self:call(program)
    ---@type Program?
    local program = self:program()
    while program do
        if program.update then
            program:update()
        end
        if program.draw then
            program:draw()
        end
        ---@diagnostic disable-next-line: undefined-field
        self:event(os.pullEventRaw())
        program = self:program()
    end
end

local Program
Program = {
    meta = {
        __name = "app"
    }
}
function Program.new(opts)
    ---@alias UpdateMethod fun(self: Program)
    ---@alias DrawMethod fun(self: Program)
    ---@alias EventHandle fun(self: Program, ...)
    ---@class Program : { update: UpdateMethod?, draw: DrawMethod?, events: table<string, EventHandle> }
    return setmetatable({
        update = opts.update,
        draw = opts.draw,
        events = opts.events or {},
    }, Program.meta)
end

return {
    app = App.new,
    program = Program.new
}