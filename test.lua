local Luxt1 = {}

function Luxt1.Window(config)
    local libName = config.Title or config.title or "LuxtLib"
    local windowSize = config.Size or config.size or Vector2.new(580, 460)

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local windowW = windowSize.X
    local windowH = windowSize.Y
    local sideW = 155
    local contentPadX = 8
    local contentPadY = 8
    local tabH = 28
    local tabPad = 4
    local sectionHeaderH = 32
    local elemH = 32
    local elemPad = 3
    local sectionPad = 5
    local dropItemH = 28

    local Internal = {
        Running = true,
        Open = true,
        Dragging = false,
        DragStart = Vector2.new(0, 0),
        Position = Vector2.new(300, 100),
        ActiveTab = nil,
        ActiveSlider = nil,
        FocusedTextBox = nil,
        ListeningKeybind = nil,
        ListeningToggleKey = false,
        ToggleKeyCode = 0x12,
        ToggleKeyName = "Alt",
        ScrollOffset = 0,
        MaxScroll = 0,
        PrevMouse1 = false,
        PrevKeys = {},
        OpenDropdown = nil,
    }

    local tabs = {}
    local allDrawings = {}
    local allKeybindElems = {}

    local KeyNames = {
        [8]="Backspace",[9]="Tab",[13]="Enter",[16]="Shift",[17]="Ctrl",
        [18]="Alt",[19]="Pause",[20]="CapsLock",[27]="Esc",[32]="Space",
        [33]="PageUp",[34]="PageDown",[35]="End",[36]="Home",
        [37]="Left",[38]="Up",[39]="Right",[40]="Down",
        [45]="Insert",[46]="Delete",
        [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",
        [53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
        [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",
        [71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",
        [77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",
        [83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",
        [89]="Y",[90]="Z",
        [112]="F1",[113]="F2",[114]="F3",[115]="F4",[116]="F5",
        [117]="F6",[118]="F7",[119]="F8",[120]="F9",[121]="F10",
        [122]="F11",[123]="F12",
    }

    local vkToChar = {
        [65]="a",[66]="b",[67]="c",[68]="d",[69]="e",[70]="f",
        [71]="g",[72]="h",[73]="i",[74]="j",[75]="k",[76]="l",
        [77]="m",[78]="n",[79]="o",[80]="p",[81]="q",[82]="r",
        [83]="s",[84]="t",[85]="u",[86]="v",[87]="w",[88]="x",
        [89]="y",[90]="z",
        [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",
        [53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
        [32]=" ",[190]=".",[188]=",",[189]="-",[187]="=",
    }

    local vkToCharShift = {
        [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",
        [71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",
        [77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",
        [83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",
        [89]="Y",[90]="Z",
        [49]="!",[50]="@",[51]="#",[52]="$",[53]="%",
        [54]="^",[55]="&",[56]="*",[57]="(",[48]=")",
        [189]="_",[187]="+",
    }

    local C = {
        shadow = Color3.fromRGB(10, 10, 10),
        bg = Color3.fromRGB(30, 30, 30),
        side = Color3.fromRGB(21, 21, 21),
        accent = Color3.fromRGB(153, 255, 238),
        accentDim = Color3.fromRGB(35, 59, 55),
        accentMid = Color3.fromRGB(103, 172, 161),
        elemBg = Color3.fromRGB(18, 18, 18),
        elemBgPress = Color3.fromRGB(101, 168, 157),
        textPrimary = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 180),
        textDim = Color3.fromRGB(97, 97, 97),
        inputBg = Color3.fromRGB(24, 24, 24),
        sliderTrack = Color3.fromRGB(24, 24, 24),
        sectionBg = Color3.fromRGB(21, 21, 21),
        dropOptionBg = Color3.fromRGB(51, 51, 51),
        dropOptionSel = Color3.fromRGB(28, 72, 120),
        dropOptionText = Color3.fromRGB(120, 200, 187),
        black = Color3.fromRGB(0, 0, 0),
        yellow = Color3.fromRGB(255, 255, 0),
    }

    local function makeSquare(p)
        local s = Drawing.new("Square")
        s.Filled = true
        s.Color = p.Color or Color3.new(1,1,1)
        s.Position = p.Position or Vector2.new(0,0)
        s.Size = p.Size or Vector2.new(0,0)
        s.Transparency = p.Transparency or 1
        s.Visible = false
        s.ZIndex = p.ZIndex or 1
        pcall(function() s.Corner = p.Corner or 0 end)
        table.insert(allDrawings, s)
        return s
    end

    local function makeText(p)
        local t = Drawing.new("Text")
        t.Text = p.Text or ""
        t.Color = p.Color or Color3.new(1,1,1)
        t.Position = p.Position or Vector2.new(0,0)
        t.Size = p.FontSize or 14
        t.Font = p.Font or Drawing.Fonts.System
        t.Center = p.Center or false
        t.Visible = false
        t.ZIndex = p.ZIndex or 2
        t.Outline = p.Outline or false
        t.Transparency = p.Transparency or 1
        table.insert(allDrawings, t)
        return t
    end

    local function makeLine(p)
        local l = Drawing.new("Line")
        l.Color = p.Color or Color3.new(1,1,1)
        l.From = p.From or Vector2.new(0,0)
        l.To = p.To or Vector2.new(0,0)
        l.Thickness = p.Thickness or 1
        l.Visible = false
        l.ZIndex = p.ZIndex or 2
        l.Transparency = p.Transparency or 1
        table.insert(allDrawings, l)
        return l
    end

    local function isMouseInRect(px, py, pw, ph)
        local mx, my = Mouse.X, Mouse.Y
        return mx >= px and mx <= px + pw and my >= py and my <= py + ph
    end

    local function estW(text, fs)
        return #text * (fs * 0.52)
    end

    local function shiftHeld()
        local ok, p = pcall(iskeypressed, 0x10)
        return ok and p
    end

    -- Window chrome
    local shadowBg = makeSquare({Color=C.shadow, ZIndex=0, Corner=7, Transparency=0.3})
    local mainBg = makeSquare({Color=C.bg, ZIndex=1, Corner=5})
    local sideBg = makeSquare({Color=C.side, ZIndex=2, Corner=5})
    local sideCover = makeSquare({Color=C.side, ZIndex=2})
    local divLine = makeLine({Color=C.accentDim, ZIndex=3, Thickness=1})
    local hubText = makeText({Text=libName, Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=3})
    local userText = makeText({Text=LocalPlayer.Name, Color=C.accentMid, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=3})
    local togBtnW, togBtnH = 85, 24
    local togBg = makeSquare({Color=C.inputBg, ZIndex=3, Corner=5})
    local togTxt = makeText({Text="[ Alt ]", Color=C.accent, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=4, Center=true, Outline=true})
    local togLbl = makeText({Text="Toggle", Color=C.textSecondary, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=3})

    local function getContentX() return Internal.Position.X + sideW + contentPadX end
    local function getContentY() return Internal.Position.Y + contentPadY end
    local function getContentW() return windowW - sideW - contentPadX * 2 end
    local function getContentH() return windowH - contentPadY * 2 end

    local function Update()
        if not Internal.Open then
            for _, d in ipairs(allDrawings) do
                d.Visible = false
            end
            return
        end

        local wx, wy = Internal.Position.X, Internal.Position.Y

        shadowBg.Position = Vector2.new(wx-4, wy-4)
        shadowBg.Size = Vector2.new(windowW+8, windowH+8)
        shadowBg.Visible = true

        mainBg.Position = Vector2.new(wx, wy)
        mainBg.Size = Vector2.new(windowW, windowH)
        mainBg.Visible = true

        sideBg.Position = Vector2.new(wx, wy)
        sideBg.Size = Vector2.new(sideW, windowH)
        sideBg.Visible = true

        sideCover.Position = Vector2.new(wx+sideW-5, wy)
        sideCover.Size = Vector2.new(5, windowH)
        sideCover.Visible = true

        divLine.From = Vector2.new(wx+10, wy+60)
        divLine.To = Vector2.new(wx+sideW-10, wy+60)
        divLine.Visible = true

        hubText.Position = Vector2.new(wx+15, wy+12)
        hubText.Visible = true

        userText.Position = Vector2.new(wx+15, wy+32)
        userText.Visible = true

        local kbX, kbY = wx+8, wy+windowH-38
        togBg.Position = Vector2.new(kbX, kbY)
        togBg.Size = Vector2.new(togBtnW, togBtnH)
        togBg.Visible = true

        if Internal.ListeningToggleKey then
            togTxt.Text = "..."
            togTxt.Color = C.yellow
        else
            togTxt.Text = "[ "..Internal.ToggleKeyName.." ]"
            togTxt.Color = C.accent
        end
        togTxt.Position = Vector2.new(kbX+togBtnW/2, kbY+togBtnH/2-7)
        togTxt.Visible = true

        togLbl.Position = Vector2.new(kbX+togBtnW+6, kbY+togBtnH/2-6)
        togLbl.Visible = true

        local tabY = wy + 70
        for _, tab in ipairs(tabs) do
            tab.btnDraw.Position = Vector2.new(wx+15, tabY)
            tab.btnDraw.Color = (Internal.ActiveTab == tab) and C.accent or C.accentDim
            tab.btnDraw.Visible = true
            tab.btnY = tabY
            tabY = tabY + tabH + tabPad
        end

        -- Hide all elements first
        for _, tab in ipairs(tabs) do
            for _, sec in ipairs(tab.sections) do
                sec.hdrBg.Visible = false
                sec.hdrTxt.Visible = false
                sec.arrow.Visible = false
                for _, el in ipairs(sec.elements) do
                    el.hide()
                end
            end
        end

        -- Calculate total content height
        local totalContentH = 0
        if Internal.ActiveTab then
            for _, sec in ipairs(Internal.ActiveTab.sections) do
                totalContentH = totalContentH + sectionHeaderH + elemPad
                if sec.open then
                    for _, el in ipairs(sec.elements) do
                        totalContentH = totalContentH + el.getHeight() + elemPad
                    end
                end
                totalContentH = totalContentH + sectionPad
            end
        end

        Internal.MaxScroll = math.max(0, totalContentH - getContentH())
        Internal.ScrollOffset = math.clamp(Internal.ScrollOffset, 0, Internal.MaxScroll)

        if Internal.ActiveTab then
            local cy = getContentY() - Internal.ScrollOffset
            local cx = getContentX()
            local cw = getContentW()
            local viewTop = getContentY()
            local viewBottom = getContentY() + getContentH()

            for _, sec in ipairs(Internal.ActiveTab.sections) do
                local hdrVis = (cy + sectionHeaderH > viewTop) and (cy < viewBottom)
                
                sec.hdrBg.Position = Vector2.new(cx, cy)
                sec.hdrBg.Size = Vector2.new(cw, sectionHeaderH)
                sec.hdrBg.Visible = hdrVis

                sec.hdrTxt.Position = Vector2.new(cx+10, cy+sectionHeaderH/2-7)
                sec.hdrTxt.Visible = hdrVis

                sec.arrow.Text = sec.open and "v" or ">"
                sec.arrow.Position = Vector2.new(cx+cw-20, cy+sectionHeaderH/2-7)
                sec.arrow.Visible = hdrVis

                sec.posY = cy
                sec.headerEndY = cy + sectionHeaderH
                cy = cy + sectionHeaderH + elemPad

                if sec.open then
                    for _, el in ipairs(sec.elements) do
                        local h = el.getHeight()
                        local elemVis = (cy + h > viewTop) and (cy < viewBottom)
                        el.posY = cy
                        el.posX = cx + 8
                        el.width = cw - 16
                        el.update(cx, cy, cw, h, elemVis)
                        cy = cy + h + elemPad
                    end
                end
                cy = cy + sectionPad
            end
        end
    end

    spawn(function()
        for i = 1, 255 do
            Internal.PrevKeys[i] = false
        end
        Internal.PrevMouse1 = ismouse1pressed()

        while Internal.Running do
            local mx, my = Mouse.X, Mouse.Y
            local m1 = ismouse1pressed()
            local m1Click = m1 and not Internal.PrevMouse1

            local newKeys = {}
            for i = 1, 255 do
                local ok, pressed = pcall(iskeypressed, i)
                if ok and pressed and not Internal.PrevKeys[i] then
                    newKeys[i] = true
                end
                Internal.PrevKeys[i] = ok and pressed or false
            end

            -- Toggle key listening
            if Internal.ListeningToggleKey then
                for vk, _ in pairs(newKeys) do
                    Internal.ToggleKeyCode = vk
                    Internal.ToggleKeyName = KeyNames[vk] or string.format("0x%X", vk)
                    Internal.ListeningToggleKey = false
                    break
                end
            -- Keybind listening
            elseif Internal.ListeningKeybind then
                for vk, _ in pairs(newKeys) do
                    Internal.ListeningKeybind.keyCode = vk
                    Internal.ListeningKeybind.keyName = KeyNames[vk] or string.format("0x%X", vk)
                    Internal.ListeningKeybind.listening = false
                    Internal.ListeningKeybind = nil
                    break
                end
            else
                -- Toggle UI
                if newKeys[Internal.ToggleKeyCode] then
                    Internal.Open = not Internal.Open
                end

                -- Fire keybind callbacks
                if Internal.Open then
                    for _, kb in ipairs(allKeybindElems) do
                        if not kb.listening and newKeys[kb.keyCode] then
                            if kb.callback then kb.callback() end
                        end
                    end
                end

                -- TextBox input
                if Internal.Open and Internal.FocusedTextBox then
                    local tb = Internal.FocusedTextBox
                    if newKeys[0x0D] then
                        if tb.callback then tb.callback(tb.text) end
                        tb.text = ""
                        Internal.FocusedTextBox = nil
                    elseif newKeys[0x1B] then
                        Internal.FocusedTextBox = nil
                    elseif newKeys[0x08] then
                        if #tb.text > 0 then
                            tb.text = tb.text:sub(1, -2)
                        end
                    else
                        local shift = shiftHeld()
                        for vk, _ in pairs(newKeys) do
                            local ch = (shift and vkToCharShift[vk]) or vkToChar[vk]
                            if ch then
                                tb.text = tb.text .. ch
                                break
                            end
                        end
                    end
                end
            end

            if Internal.Open then
                -- Dragging
                if Internal.Dragging then
                    if m1 then
                        Internal.Position = Vector2.new(mx - Internal.DragStart.X, my - Internal.DragStart.Y)
                    else
                        Internal.Dragging = false
                    end
                end

                -- Slider dragging
                if Internal.ActiveSlider then
                    if m1 then
                        local slider = Internal.ActiveSlider
                        local pct = math.clamp((mx - slider.trackX) / slider.trackW, 0, 1)
                        local newVal = math.floor(slider.min + pct * (slider.max - slider.min))
                        if newVal ~= slider.value then
                            slider.value = newVal
                            if slider.callback then slider.callback(newVal) end
                        end
                    else
                        Internal.ActiveSlider = nil
                    end
                end

                -- Click handling
                if m1Click and not Internal.Dragging and not Internal.ActiveSlider then
                    local wx, wy = Internal.Position.X, Internal.Position.Y
                    local handled = false

                    -- Dropdown options first
                    if Internal.OpenDropdown and Internal.OpenDropdown.isOpen then
                        local dd = Internal.OpenDropdown
                        local oy = dd.lastY + elemH + elemPad
                        for i = 1, #dd.options do
                            if isMouseInRect(dd.lastX, oy, dd.lastW, dropItemH) then
                                dd.selected = dd.options[i]
                                if dd.callback then dd.callback(dd.options[i]) end
                                dd.isOpen = false
                                Internal.OpenDropdown = nil
                                handled = true
                                break
                            end
                            oy = oy + dropItemH + elemPad
                        end
                    end

                    if not handled then
                        -- Toggle key button
                        local kbX, kbY = wx+8, wy+windowH-38
                        if isMouseInRect(kbX, kbY, togBtnW, togBtnH) then
                            Internal.ListeningToggleKey = true
                            handled = true
                        -- Drag area
                        elseif isMouseInRect(wx, wy, sideW, 60) then
                            Internal.Dragging = true
                            Internal.DragStart = Vector2.new(mx - wx, my - wy)
                            handled = true
                        else
                            -- Tab buttons
                            for _, tab in ipairs(tabs) do
                                if isMouseInRect(wx+5, tab.btnY-2, sideW-10, tabH) then
                                    Internal.ActiveTab = tab
                                    Internal.ScrollOffset = 0
                                    if Internal.OpenDropdown then
                                        Internal.OpenDropdown.isOpen = false
                                        Internal.OpenDropdown = nil
                                    end
                                    handled = true
                                    break
                                end
                            end

                            -- Content area
                            if not handled and Internal.ActiveTab then
                                local viewTop = getContentY()
                                local viewBottom = getContentY() + getContentH()
                                
                                for _, sec in ipairs(Internal.ActiveTab.sections) do
                                    if handled then break end
                                    
                                    -- Elements first
                                    if sec.open then
                                        for _, el in ipairs(sec.elements) do
                                            if el.posY and el.posY > 0 then
                                                if my >= el.posY and my <= el.posY + el.getHeight() then
                                                    if mx >= el.posX and mx <= el.posX + el.width then
                                                        if el.onClick() then
                                                            handled = true
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    
                                    -- Section header
                                    if not handled and sec.posY then
                                        if my >= sec.posY and my < sec.headerEndY then
                                            if mx >= getContentX() and mx <= getContentX() + getContentW() then
                                                sec.open = not sec.open
                                                if Internal.OpenDropdown then
                                                    Internal.OpenDropdown.isOpen = false
                                                    Internal.OpenDropdown = nil
                                                end
                                                handled = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Close dropdown if clicked elsewhere
                    if not handled and Internal.OpenDropdown then
                        Internal.OpenDropdown.isOpen = false
                        Internal.OpenDropdown = nil
                    end
                end

                -- Scroll with arrow keys
                if isMouseInRect(getContentX(), getContentY(), getContentW(), getContentH()) then
                    if newKeys[0x26] then
                        Internal.ScrollOffset = math.clamp(Internal.ScrollOffset - 30, 0, Internal.MaxScroll)
                    elseif newKeys[0x28] then
                        Internal.ScrollOffset = math.clamp(Internal.ScrollOffset + 30, 0, Internal.MaxScroll)
                    end
                end
            end

            Internal.PrevMouse1 = m1
            wait(0.01)
        end
    end)

    spawn(function()
        while Internal.Running do
            wait()
            Update()
        end

        for _, d in ipairs(allDrawings) do
            pcall(function() d:Remove() end)
        end
    end)

    local WindowAPI = {}

    function WindowAPI:Tab(config)
        local tabText = config.Title or config.title or "Tab"
        local btnDraw = makeText({Text=tabText, Color=C.accent, FontSize=14, Font=Drawing.Fonts.System, ZIndex=3})
        
        local tab = {
            name = tabText,
            btnDraw = btnDraw,
            btnY = 0,
            sections = {},
        }
        
        table.insert(tabs, tab)
        if not Internal.ActiveTab then
            Internal.ActiveTab = tab
        end

        local TabAPI = {}

        function TabAPI:Section(config)
            local secText = config.Title or config.title or "Section"
            
            local hdrBg = makeSquare({Color=C.sectionBg, ZIndex=3, Corner=5})
            local hdrTxt = makeText({Text=secText, Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=4})
            local arrow = makeText({Text="v", Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=4, Outline=true})

            local section = {
                name = secText,
                open = true,
                hdrBg = hdrBg,
                hdrTxt = hdrTxt,
                arrow = arrow,
                posY = 0,
                headerEndY = 0,
                elements = {},
            }

            table.insert(tab.sections, section)

            local SectionAPI = {}

            function SectionAPI:Button(config)
                local text = config.Title or config.title or config.Text or config.text or "Button"
                local cb = config.Callback or config.callback or function() end
                
                local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
                local tx = makeText({Text=text, Color=C.textSecondary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5, Center=true})

                local elem = {
                    posY = 0, posX = 0, width = 0,
                    getHeight = function() return elemH end,
                    hide = function()
                        bg.Visible = false
                        tx.Visible = false
                    end,
                    update = function(x, y, w, h, vis)
                        bg.Position = Vector2.new(x+8, y)
                        bg.Size = Vector2.new(w-16, h)
                        bg.Visible = vis
                        tx.Position = Vector2.new(x+8+(w-16)/2, y+h/2-7)
                        tx.Visible = vis
                    end,
                    onClick = function()
                        spawn(function()
                            bg.Color = C.elemBgPress
                            tx.Color = C.black
                            wait(0.15)
                            bg.Color = C.elemBg
                            tx.Color = C.textSecondary
                        end)
                        cb()
                        return true
                    end,
                }
                table.insert(section.elements, elem)
            end

            function SectionAPI:Toggle(config)
                local text = config.Title or config.title or config.Text or config.text or "Toggle"
                local cb = config.Callback or config.callback or function() end
                local defaultState = config.Default or config.default or false
                
                local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
                local ckBg = makeSquare({Color=C.inputBg, ZIndex=5, Corner=3})
                local ck = makeText({Text=defaultState and "O" or "X", Color=defaultState and C.accent or C.textDim, FontSize=16, Font=Drawing.Fonts.SystemBold, ZIndex=6, Center=true})
                local lb = makeText({Text=text, Color=defaultState and C.accent or C.textDim, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
                
                local state = { on = defaultState }

                local elem = {
                    posY = 0, posX = 0, width = 0,
                    getHeight = function() return elemH end,
                    hide = function()
                        bg.Visible = false
                        ckBg.Visible = false
                        ck.Visible = false
                        lb.Visible = false
                    end,
                    update = function(x, y, w, h, vis)
                        bg.Position = Vector2.new(x+8, y)
                        bg.Size = Vector2.new(w-16, h)
                        bg.Visible = vis
                        ckBg.Position = Vector2.new(x+16, y+4)
                        ckBg.Size = Vector2.new(24, 24)
                        ckBg.Visible = vis
                        ck.Position = Vector2.new(x+16+12, y+h/2-8)
                        ck.Visible = vis
                        lb.Position = Vector2.new(x+48, y+h/2-7)
                        lb.Visible = vis
                        if state.on then
                            ck.Color = C.accent
                            lb.Color = C.accent
                            ck.Text = "O"
                        else
                            ck.Color = C.textDim
                            lb.Color = C.textDim
                            ck.Text = "X"
                        end
                    end,
                    onClick = function()
                        state.on = not state.on
                        cb(state.on)
                        return true
                    end,
                }
                table.insert(section.elements, elem)
                
                if defaultState then
                    cb(defaultState)
                end
            end

            function SectionAPI:Slider(config)
                local text = config.Title or config.title or "Slider"
                local min = config.Min or config.min or 0
                local max = config.Max or config.max or 100
                local defaultVal = config.Default or config.default or min
                local cb = config.Callback or config.callback or function() end
                
                local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
                local trackBg = makeSquare({Color=C.sliderTrack, ZIndex=5, Corner=3})
                local fill = makeSquare({Color=C.accent, ZIndex=6, Corner=3})
                local lb = makeText({Text=text, Color=C.textPrimary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
                local valTxt = makeText({Text=tostring(defaultVal), Color=C.accent, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=5})
                
                local trackW = 150
                local slider = {
                    value = defaultVal,
                    min = min,
                    max = max,
                    callback = cb,
                    trackX = 0,
                    trackW = trackW,
                }

                local elem = {
                    posY = 0, posX = 0, width = 0,
                    getHeight = function() return elemH end,
                    hide = function()
                        bg.Visible = false
                        trackBg.Visible = false
                        fill.Visible = false
                        lb.Visible = false
                        valTxt.Visible = false
                    end,
                    update = function(x, y, w, h, vis)
                        bg.Position = Vector2.new(x+8, y)
                        bg.Size = Vector2.new(w-16, h)
                        bg.Visible = vis
                        
                        local sx = x + 16
                        local sy = y + h/2 - 3
                        slider.trackX = sx
                        
                        trackBg.Position = Vector2.new(sx, sy)
                        trackBg.Size = Vector2.new(trackW, 6)
                        trackBg.Visible = vis
                        
                        local pct = (max > min) and math.clamp((slider.value - min) / (max - min), 0, 1) or 0
                        fill.Position = Vector2.new(sx, sy)
                        fill.Size = Vector2.new(math.max(math.floor(trackW * pct), 1), 6)
                        fill.Visible = vis
                        
                        lb.Position = Vector2.new(sx + trackW + 12, y + h/2 - 7)
                        lb.Visible = vis
                        
                        valTxt.Text = tostring(slider.value)
                        valTxt.Position = Vector2.new(sx + trackW + 12 + estW(text, 14) + 8, y + h/2 - 6)
                        valTxt.Visible = vis
                    end,
                    onClick = function()
                        Internal.ActiveSlider = slider
                        local pct = math.clamp((Mouse.X - slider.trackX) / trackW, 0, 1)
                        slider.value = math.floor(min + pct * (max - min))
                        cb(slider.value)
                        return true
                    end,
                }
                table.insert(section.elements, elem)
                
                cb(defaultVal)
            end

            function SectionAPI:Keybind(config)
                local text = config.Title or config.title or "KeyBind"
                local defaultKey = config.Default or config.default or 0x46
                local cb = config.Callback or config.callback or function() end
                
                local keyName = KeyNames[defaultKey] or string.format("0x%X", defaultKey)
                
                local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
                local kW, kH = 85, 24
                local kBg = makeSquare({Color=C.inputBg, ZIndex=5, Corner=5})
                local kTx = makeText({Text="[ "..keyName.." ]", Color=C.accent, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=6, Center=true, Outline=true})
                local lb = makeText({Text=text, Color=C.textPrimary, FontSize=13, Font=Drawing.Fonts.SystemBold, ZIndex=5})
                
                local keybind = {
                    keyCode = defaultKey,
                    keyName = keyName,
                    callback = cb,
                    listening = false,
                }
                table.insert(allKeybindElems, keybind)

                local elem = {
                    posY = 0, posX = 0, width = 0,
                    btnX = 0, btnY = 0,
                    getHeight = function() return elemH end,
                    hide = function()
                        bg.Visible = false
                        kBg.Visible = false
                        kTx.Visible = false
                        lb.Visible = false
                    end,
                    update = function(x, y, w, h, vis)
                        bg.Position = Vector2.new(x+8, y)
                        bg.Size = Vector2.new(w-16, h)
                        bg.Visible = vis
                        
                        local bx, by = x+16, y+(h-kH)/2
                        elem.btnX = bx
                        elem.btnY = by
                        
                        kBg.Position = Vector2.new(bx, by)
                        kBg.Size = Vector2.new(kW, kH)
                        kBg.Visible = vis
                        
                        if keybind.listening then
                            kTx.Text = "..."
                            kTx.Color = C.yellow
                        else
                            kTx.Text = "[ "..keybind.keyName.." ]"
                            kTx.Color = C.accent
                        end
                        kTx.Position = Vector2.new(bx+kW/2, by+kH/2-7)
                        kTx.Visible = vis
                        
                        lb.Position = Vector2.new(bx+kW+10, y+h/2-7)
                        lb.Visible = vis
                    end,
                    onClick = function()
                        keybind.listening = true
                        Internal.ListeningKeybind = keybind
                        return true
                    end,
                }
                table.insert(section.elements, elem)
            end

            function SectionAPI:Dropdown(config)
                local title = config.Title or config.title or "Dropdown"
                local options = config.Options or config.options or {}
                local defaultOption = config.Default or config.default or options[1]
                local cb = config.Callback or config.callback or function() end
                
                local hdrBg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=3})
                local hdrTx = makeText({Text=title..": "..(defaultOption or ""), Color=C.accent, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5})
                local hdrArr = makeText({Text="v", Color=C.accent, FontSize=12, Font=Drawing.Fonts.SystemBold, ZIndex=5, Outline=true})
                
                local optionDrawings = {}
                for i = 1, #options do
                    local bg = Drawing.new("Square")
                    bg.Filled = true
                    bg.Color = C.dropOptionBg
                    bg.Size = Vector2.new(100, dropItemH)
                    bg.Visible = false
                    bg.ZIndex = 100
                    table.insert(allDrawings, bg)
                    
                    local txt = Drawing.new("Text")
                    txt.Text = options[i]
                    txt.Color = C.dropOptionText
                    txt.Size = 14
                    txt.Font = Drawing.Fonts.SystemBold
                    txt.Visible = false
                    txt.ZIndex = 101
                    txt.Outline = true
                    table.insert(allDrawings, txt)
                    
                    optionDrawings[i] = {bg = bg, txt = txt}
                end
                
                local dropState = {
                    isOpen = false,
                    selected = defaultOption or "",
                    options = options,
                    callback = cb,
                    lastX = 0,
                    lastY = 0,
                    lastW = 0,
                }

                local elem = {
                    posY = 0, posX = 0, width = 0,
                    getHeight = function()
                        if dropState.isOpen then
                            return elemH + (#options * (dropItemH + elemPad))
                        end
                        return elemH
                    end,
                    hide = function()
                        hdrBg.Visible = false
                        hdrTx.Visible = false
                        hdrArr.Visible = false
                        for i = 1, #options do
                            optionDrawings[i].bg.Visible = false
                            optionDrawings[i].txt.Visible = false
                        end
                    end,
                    update = function(x, y, w, h, vis)
                        dropState.lastX = x + 8
                        dropState.lastY = y
                        dropState.lastW = w - 16
                        
                        hdrBg.Position = Vector2.new(x+8, y)
                        hdrBg.Size = Vector2.new(w-16, elemH)
                        hdrBg.Visible = vis
                        
                        hdrTx.Text = title..": "..dropState.selected
                        hdrTx.Position = Vector2.new(x+18, y+elemH/2-7)
                        hdrTx.Visible = vis
                        
                        hdrArr.Text = dropState.isOpen and "^" or "v"
                        hdrArr.Position = Vector2.new(x+w-28, y+elemH/2-6)
                        hdrArr.Visible = vis
                        
                        if dropState.isOpen and vis then
                            local oy = y + elemH + elemPad
                            for i = 1, #options do
                                optionDrawings[i].bg.Position = Vector2.new(x+12, oy)
                                optionDrawings[i].bg.Size = Vector2.new(w-24, dropItemH)
                                optionDrawings[i].bg.Visible = true
                                
                                if options[i] == dropState.selected then
                                    optionDrawings[i].bg.Color = C.dropOptionSel
                                else
                                    optionDrawings[i].bg.Color = C.dropOptionBg
                                end
                                
                                optionDrawings[i].txt.Text = options[i]
                                optionDrawings[i].txt.Position = Vector2.new(x+20, oy + dropItemH/2 - 7)
                                optionDrawings[i].txt.Visible = true
                                
                                oy = oy + dropItemH + elemPad
                            end
                        else
                            for i = 1, #options do
                                optionDrawings[i].bg.Visible = false
                                optionDrawings[i].txt.Visible = false
                            end
                        end
                    end,
                    onClick = function()
                        if dropState.isOpen then
                            dropState.isOpen = false
                            Internal.OpenDropdown = nil
                        else
                            if Internal.OpenDropdown then
                                Internal.OpenDropdown.isOpen = false
                            end
                            dropState.isOpen = true
                            Internal.OpenDropdown = dropState
                        end
                        return true
                    end,
                }
                table.insert(section.elements, elem)
                
                if defaultOption then
                    cb(defaultOption)
                end
            end

            function SectionAPI:Label(config)
                local text = config.Title or config.title or config.Text or config.text or "Label"
                local bg = makeSquare({Color=C.elemBg, ZIndex=4, Corner=5})
                local tx = makeText({Text=text, Color=C.textPrimary, FontSize=14, Font=Drawing.Fonts.SystemBold, ZIndex=5, Center=true})
                
                local elem = {
                    posY = 0, posX = 0, width = 0,
                    getHeight = function() return elemH end,
                    hide = function()
                        bg.Visible = false
                        tx.Visible = false
                    end,
                    update = function(x, y, w, h, vis)
                        bg.Position = Vector2.new(x+8, y)
                        bg.Size = Vector2.new(w-16, h)
                        bg.Visible = vis
                        tx.Position = Vector2.new(x+8+(w-16)/2, y+h/2-7)
                        tx.Visible = vis
                    end,
                    onClick = function() return false end,
                }
                table.insert(section.elements, elem)
            end

            return SectionAPI
        end

        return TabAPI
    end

    return WindowAPI
end

-- Create global UI table
_G.UI = Luxt1
_G.Flags = {}

notify("UI Library Loaded!", "Success", 2)
