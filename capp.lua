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
        event = App.event,
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
function App:event(name, ...)
    local program = self:program()
    if not program then
        return
    end
    local handle = program.events[name]
    if handle then
        local ret = handle(self, ...)
        return type(ret) == "nil" and true or ret
    elseif name == "terminate" then
        error "Terminated"
    else
        return false
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
            program.update(self)
        end
        if program.draw then
            program.draw(self)
        end
        ---@diagnostic disable-next-line: undefined-field
        while not self:event(os.pullEventRaw()) do end
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
    ---@alias UpdateMethod fun(app: App)
    ---@alias DrawMethod fun(app: App)
    ---@alias EventHandle fun(app: App, ...)
    ---@class Program : { update: UpdateMethod?, draw: DrawMethod?, events: table<string, EventHandle> }
    return setmetatable({
        update = opts.update,
        draw = opts.draw,
        events = opts.events or {},
        event = Program.event,
    }, Program.meta)
end

return {
    app = App.new,
    program = Program.new
}
