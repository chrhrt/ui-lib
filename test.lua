local Luxt1 = {}

-- Helper: Check if mouse is over a region
local function isMouseOver(pos, size, mousePos)
    return mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
           mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
end

-- Helper: Get key name from code
local function getKeyName(keyCode)
    local KeyNames = {
        [48] = "0", [49] = "1", [50] = "2", [51] = "3", [52] = "4",
        [53] = "5", [54] = "6", [55] = "7", [56] = "8", [57] = "9",
        [8] = "Backspace", [9] = "Tab", [13] = "Enter", [16] = "Shift",
        [17] = "Ctrl", [18] = "Alt", [27] = "Esc", [32] = "Space",
        [37] = "Left", [38] = "Up", [39] = "Right", [40] = "Down",
        [45] = "Insert", [46] = "Delete",
        [65] = "A", [66] = "B", [67] = "C", [68] = "D", [69] = "E",
        [70] = "F", [71] = "G", [72] = "H", [73] = "I", [74] = "J",
        [75] = "K", [76] = "L", [77] = "M", [78] = "N", [79] = "O",
        [80] = "P", [81] = "Q", [82] = "R", [83] = "S", [84] = "T",
        [85] = "U", [86] = "V", [87] = "W", [88] = "X", [89] = "Y",
        [90] = "Z",
        [112] = "F1", [113] = "F2", [114] = "F3", [115] = "F4",
        [116] = "F5", [117] = "F6", [118] = "F7", [119] = "F8",
        [120] = "F9", [121] = "F10", [122] = "F11", [123] = "F12",
    }
    return KeyNames[keyCode] or "Unknown"
end

function Luxt1.CreateWindow(libName, logoId)
    libName = libName or "LuxtLib"
    
    local Mouse = game.Players.LocalPlayer:GetMouse()
    local Players = game:GetService("Players")
    
    -- All drawing objects
    local allDrawings = {}
    local visible = true
    local basePos = Vector2.new(400, 150)
    
    -- Window state
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local dragOffset = Vector2.new(0, 0)
    local lastMouse1 = false
    
    -- Main shadow
    local shadow = Drawing.new("Square")
    shadow.Position = basePos
    shadow.Size = Vector2.new(609, 530)
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Transparency = 0.8
    shadow.Filled = true
    shadow.Visible = true
    shadow.ZIndex = 0
    table.insert(allDrawings, shadow)
    
    -- Main frame
    local mainFrame = Drawing.new("Square")
    mainFrame.Position = basePos + Vector2.new(29, 40)
    mainFrame.Size = Vector2.new(553, 452)
    mainFrame.Color = Color3.fromRGB(30, 30, 30)
    mainFrame.Filled = true
    mainFrame.Corner = 5
    mainFrame.ZIndex = 1
    table.insert(allDrawings, mainFrame)
    
    -- Side heading
    local sideHeading = Drawing.new("Square")
    sideHeading.Position = basePos + Vector2.new(29, 40)
    sideHeading.Size = Vector2.new(155, 452)
    sideHeading.Color = Color3.fromRGB(21, 21, 21)
    sideHeading.Filled = true
    sideHeading.Corner = 5
    sideHeading.ZIndex = 2
    table.insert(allDrawings, sideHeading)
    
    -- Side cover (removes corner on right side)
    local sideCover = Drawing.new("Square")
    sideCover.Position = sideHeading.Position + Vector2.new(141, 0)
    sideCover.Size = Vector2.new(14, 452)
    sideCover.Color = Color3.fromRGB(21, 21, 21)
    sideCover.Filled = true
    sideCover.ZIndex = 2
    table.insert(allDrawings, sideCover)
    
    -- Hub name
    local hubName = Drawing.new("Text")
    hubName.Text = libName
    hubName.Position = sideHeading.Position + Vector2.new(45, 16)
    hubName.Size = 14
    hubName.Color = Color3.fromRGB(153, 255, 238)
    hubName.Font = Drawing.Fonts.SystemBold
    hubName.Outline = true
    hubName.ZIndex = 3
    table.insert(allDrawings, hubName)
    
    -- Username
    local username = Drawing.new("Text")
    username.Text = Players.LocalPlayer.Name
    username.Position = sideHeading.Position + Vector2.new(45, 34)
    username.Size = 12
    username.Color = Color3.fromRGB(103, 172, 161)
    username.Font = Drawing.Fonts.SystemBold
    username.Outline = true
    username.ZIndex = 3
    table.insert(allDrawings, username)
    
    -- Close keybind
    local closeKeyBg = Drawing.new("Square")
    closeKeyBg.Position = sideHeading.Position + Vector2.new(8, 422)
    closeKeyBg.Size = Vector2.new(76, 22)
    closeKeyBg.Color = Color3.fromRGB(24, 24, 24)
    closeKeyBg.Filled = true
    closeKeyBg.Corner = 5
    closeKeyBg.ZIndex = 3
    table.insert(allDrawings, closeKeyBg)
    
    local closeKeyText = Drawing.new("Text")
    closeKeyText.Text = "LeftAlt"
    closeKeyText.Position = closeKeyBg.Position + Vector2.new(38, 11)
    closeKeyText.Size = 14
    closeKeyText.Color = Color3.fromRGB(153, 255, 238)
    closeKeyText.Font = Drawing.Fonts.SystemBold
    closeKeyText.Center = true
    closeKeyText.Outline = true
    closeKeyText.ZIndex = 4
    table.insert(allDrawings, closeKeyText)
    
    local closeKeyLabel = Drawing.new("Text")
    closeKeyLabel.Text = "Close"
    closeKeyLabel.Position = closeKeyBg.Position + Vector2.new(85, 4)
    closeKeyLabel.Size = 13
    closeKeyLabel.Color = Color3.fromRGB(255, 255, 255)
    closeKeyLabel.Font = Drawing.Fonts.SystemBold
    closeKeyLabel.Outline = true
    closeKeyLabel.ZIndex = 4
    table.insert(allDrawings, closeKeyLabel)
    
    -- Toggle key
    local toggleKey = 18 -- Alt
    local listeningForKey = false
    
    -- Tab system
    local tabs = {}
    local currentTab = nil
    local tabYOffset = 57
    
    -- Content area
    local contentArea = {
        pos = mainFrame.Position + Vector2.new(164, 11),
        size = Vector2.new(381, 431)
    }
    
    -- Update all positions when window moves
    local function updatePositions()
        shadow.Position = basePos
        mainFrame.Position = basePos + Vector2.new(29, 40)
        sideHeading.Position = basePos + Vector2.new(29, 40)
        sideCover.Position = sideHeading.Position + Vector2.new(141, 0)
        hubName.Position = sideHeading.Position + Vector2.new(45, 16)
        username.Position = sideHeading.Position + Vector2.new(45, 34)
        closeKeyBg.Position = sideHeading.Position + Vector2.new(8, 422)
        closeKeyText.Position = closeKeyBg.Position + Vector2.new(38, 11)
        closeKeyLabel.Position = closeKeyBg.Position + Vector2.new(85, 4)
        contentArea.pos = mainFrame.Position + Vector2.new(164, 11)
        
        -- Update tabs
        local yOff = 57
        for _, tab in ipairs(tabs) do
            tab.bg.Position = sideHeading.Position + Vector2.new(12, yOff)
            tab.text.Position = tab.bg.Position + Vector2.new(35, 9)
            yOff = yOff + 35
            
            -- Update tab content positions
            tab:updatePositions()
        end
    end
    
    local TabHandling = {}
    
    function TabHandling:Tab(tabText, tabId)
        tabText = tabText or "Tab"
        
        local tab = {
            drawings = {},
            sections = {},
            visible = false,
            contentYOffset = 0
        }
        
        -- Tab button background
        tab.bg = Drawing.new("Square")
        tab.bg.Position = sideHeading.Position + Vector2.new(12, tabYOffset)
        tab.bg.Size = Vector2.new(135, 30)
        tab.bg.Color = Color3.fromRGB(21, 21, 21)
        tab.bg.Filled = true
        tab.bg.ZIndex = 3
        table.insert(allDrawings, tab.bg)
        table.insert(tab.drawings, tab.bg)
        
        -- Tab button text
        tab.text = Drawing.new("Text")
        tab.text.Text = tabText
        tab.text.Position = tab.bg.Position + Vector2.new(35, 9)
        tab.text.Size = 14
        tab.text.Color = Color3.fromRGB(35, 59, 55)
        tab.text.Font = Drawing.Fonts.UI
        tab.text.Outline = true
        tab.text.ZIndex = 4
        table.insert(allDrawings, tab.text)
        table.insert(tab.drawings, tab.text)
        
        tabYOffset = tabYOffset + 35
        
        -- Activate tab function
        function tab:activate()
            -- Hide all tabs
            for _, t in ipairs(tabs) do
                t.visible = false
                t.text.Color = Color3.fromRGB(35, 59, 55)
                for _, drawing in ipairs(t.contentDrawings or {}) do
                    drawing.Visible = false
                end
            end
            
            -- Show this tab
            self.visible = true
            self.text.Color = Color3.fromRGB(153, 255, 238)
            for _, drawing in ipairs(self.contentDrawings or {}) do
                drawing.Visible = visible
            end
            currentTab = self
        end
        
        -- Update positions for this tab's content
        function tab:updatePositions()
            if not self.contentDrawings then return end
            
            local yOff = 0
            for _, section in ipairs(self.sections) do
                section:updatePositions(yOff)
                yOff = yOff + section.totalHeight
            end
        end
        
        tab.contentDrawings = {}
        table.insert(tabs, tab)
        
        local SectionHandling = {}
        
        function SectionHandling:Section(sectionText)
            sectionText = sectionText or "Section"
            
            local section = {
                drawings = {},
                items = {},
                expanded = true,
                baseHeight = 36,
                totalHeight = 36,
                yOffset = tab.contentYOffset
            }
            
            -- Section frame
            section.frame = Drawing.new("Square")
            section.frame.Position = contentArea.pos + Vector2.new(0, tab.contentYOffset)
            section.frame.Size = Vector2.new(381, 36)
            section.frame.Color = Color3.fromRGB(21, 21, 21)
            section.frame.Filled = true
            section.frame.Corner = 5
            section.frame.ZIndex = 5
            section.frame.Visible = false
            table.insert(allDrawings, section.frame)
            table.insert(tab.contentDrawings, section.frame)
            table.insert(section.drawings, section.frame)
            
            -- Section title
            section.title = Drawing.new("Text")
            section.title.Text = sectionText
            section.title.Position = section.frame.Position + Vector2.new(9, 11)
            section.title.Size = 14
            section.title.Color = Color3.fromRGB(153, 255, 238)
            section.title.Font = Drawing.Fonts.SystemBold
            section.title.Outline = true
            section.title.ZIndex = 6
            section.title.Visible = false
            table.insert(allDrawings, section.title)
            table.insert(tab.contentDrawings, section.title)
            table.insert(section.drawings, section.title)
            
            -- Expand arrow
            section.arrow = Drawing.new("Text")
            section.arrow.Text = "▼"
            section.arrow.Position = section.frame.Position + Vector2.new(355, 11)
            section.arrow.Size = 12
            section.arrow.Color = Color3.fromRGB(153, 255, 238)
            section.arrow.Outline = true
            section.arrow.ZIndex = 6
            section.arrow.Visible = false
            table.insert(allDrawings, section.arrow)
            table.insert(tab.contentDrawings, section.arrow)
            table.insert(section.drawings, section.arrow)
            
            tab.contentYOffset = tab.contentYOffset + 39
            
            -- Toggle expand/collapse
            function section:toggle()
                self.expanded = not self.expanded
                if self.expanded then
                    self.arrow.Text = "▼"
                    for _, item in ipairs(self.items) do
                        for _, drawing in ipairs(item.drawings) do
                            drawing.Visible = visible and tab.visible
                        end
                    end
                else
                    self.arrow.Text = "▶"
                    for _, item in ipairs(self.items) do
                        for _, drawing in ipairs(item.drawings) do
                            drawing.Visible = false
                        end
                    end
                end
                self:recalculateHeight()
            end
            
            function section:recalculateHeight()
                if self.expanded then
                    local itemsHeight = 0
                    for _, item in ipairs(self.items) do
                        itemsHeight = itemsHeight + (item.height or 39)
                    end
                    self.totalHeight = self.baseHeight + itemsHeight + 3
                    self.frame.Size = Vector2.new(381, self.totalHeight)
                else
                    self.totalHeight = self.baseHeight
                    self.frame.Size = Vector2.new(381, 36)
                end
                
                -- Update tab's total content height
                tab.contentYOffset = 0
                for _, sec in ipairs(tab.sections) do
                    sec.yOffset = tab.contentYOffset
                    tab.contentYOffset = tab.contentYOffset + sec.totalHeight + 3
                end
                
                tab:updatePositions()
            end
            
            function section:updatePositions(startY)
                self.yOffset = startY or self.yOffset
                self.frame.Position = contentArea.pos + Vector2.new(0, self.yOffset)
                self.title.Position = self.frame.Position + Vector2.new(9, 11)
                self.arrow.Position = self.frame.Position + Vector2.new(355, 11)
                
                local itemY = 39
                for _, item in ipairs(self.items) do
                    item:updatePositions(itemY)
                    itemY = itemY + (item.height or 39)
                end
            end
            
            table.insert(tab.sections, section)
            
            local itemYOffset = 39
            
            local ItemHandling = {}
            
            function ItemHandling:Button(btnText, callback)
                btnText = btnText or "Button"
                callback = callback or function() end
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset
                }
                
                -- Button background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- Button text
                item.text = Drawing.new("Text")
                item.text.Text = btnText
                item.text.Position = item.bg.Position + Vector2.new(182.5, 18)
                item.text.Size = 14
                item.text.Color = Color3.fromRGB(180, 180, 180)
                item.text.Font = Drawing.Fonts.SystemBold
                item.text.Center = true
                item.text.Outline = true
                item.text.ZIndex = 8
                item.text.Visible = false
                table.insert(allDrawings, item.text)
                table.insert(tab.contentDrawings, item.text)
                table.insert(item.drawings, item.text)
                
                -- Interaction
                item.onClick = callback
                item.isButton = true
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.text.Position = self.bg.Position + Vector2.new(182.5, 18)
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:Toggle(toggleText, callback)
                toggleText = toggleText or "Toggle"
                callback = callback or function() end
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset,
                    state = false
                }
                
                -- Toggle background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- Checkbox border
                item.checkbox = Drawing.new("Square")
                item.checkbox.Position = item.bg.Position + Vector2.new(7, 8)
                item.checkbox.Size = Vector2.new(20, 20)
                item.checkbox.Color = Color3.fromRGB(97, 97, 97)
                item.checkbox.Filled = false
                item.checkbox.Thickness = 1
                item.checkbox.ZIndex = 8
                item.checkbox.Visible = false
                table.insert(allDrawings, item.checkbox)
                table.insert(tab.contentDrawings, item.checkbox)
                table.insert(item.drawings, item.checkbox)
                
                -- Checkbox fill
                item.checkFill = Drawing.new("Square")
                item.checkFill.Position = item.checkbox.Position
                item.checkFill.Size = Vector2.new(20, 20)
                item.checkFill.Color = Color3.fromRGB(153, 255, 238)
                item.checkFill.Filled = true
                item.checkFill.ZIndex = 8
                item.checkFill.Visible = false
                table.insert(allDrawings, item.checkFill)
                table.insert(tab.contentDrawings, item.checkFill)
                table.insert(item.drawings, item.checkFill)
                
                -- Toggle text
                item.text = Drawing.new("Text")
                item.text.Text = toggleText
                item.text.Position = item.bg.Position + Vector2.new(38, 11)
                item.text.Size = 14
                item.text.Color = Color3.fromRGB(97, 97, 97)
                item.text.Font = Drawing.Fonts.SystemBold
                item.text.Outline = true
                item.text.ZIndex = 8
                item.text.Visible = false
                table.insert(allDrawings, item.text)
                table.insert(tab.contentDrawings, item.text)
                table.insert(item.drawings, item.text)
                
                -- Interaction
                item.isToggle = true
                item.onToggle = callback
                
                function item:toggle()
                    self.state = not self.state
                    self.checkFill.Visible = self.state and visible and tab.visible
                    if self.state then
                        self.text.Color = Color3.fromRGB(153, 255, 238)
                        self.checkbox.Color = Color3.fromRGB(153, 255, 238)
                    else
                        self.text.Color = Color3.fromRGB(97, 97, 97)
                        self.checkbox.Color = Color3.fromRGB(97, 97, 97)
                    end
                    self.onToggle(self.state)
                end
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.checkbox.Position = self.bg.Position + Vector2.new(7, 8)
                    self.checkFill.Position = self.checkbox.Position
                    self.text.Position = self.bg.Position + Vector2.new(38, 11)
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:Label(labelText)
                labelText = labelText or "Label"
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset
                }
                
                -- Label background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- Label text
                item.text = Drawing.new("Text")
                item.text.Text = labelText
                item.text.Position = item.bg.Position + Vector2.new(182.5, 18)
                item.text.Size = 14
                item.text.Color = Color3.fromRGB(255, 255, 255)
                item.text.Font = Drawing.Fonts.SystemBold
                item.text.Center = true
                item.text.Outline = true
                item.text.ZIndex = 8
                item.text.Visible = false
                table.insert(allDrawings, item.text)
                table.insert(tab.contentDrawings, item.text)
                table.insert(item.drawings, item.text)
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.text.Position = self.bg.Position + Vector2.new(182.5, 18)
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:Slider(sliderText, minVal, maxVal, callback)
                sliderText = sliderText or "Slider"
                minVal = minVal or 0
                maxVal = maxVal or 100
                callback = callback or function() end
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset,
                    value = minVal,
                    min = minVal,
                    max = maxVal,
                    isDragging = false
                }
                
                -- Slider background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- Slider track
                item.track = Drawing.new("Square")
                item.track.Position = item.bg.Position + Vector2.new(7, 13)
                item.track.Size = Vector2.new(150, 10)
                item.track.Color = Color3.fromRGB(44, 44, 44)
                item.track.Filled = true
                item.track.ZIndex = 8
                item.track.Visible = false
                table.insert(allDrawings, item.track)
                table.insert(tab.contentDrawings, item.track)
                table.insert(item.drawings, item.track)
                
                -- Slider knob
                item.knob = Drawing.new("Square")
                item.knob.Position = item.track.Position + Vector2.new(-5, -5)
                item.knob.Size = Vector2.new(20, 20)
                item.knob.Color = Color3.fromRGB(153, 255, 238)
                item.knob.Filled = true
                item.knob.Corner = 100
                item.knob.ZIndex = 9
                item.knob.Visible = false
                table.insert(allDrawings, item.knob)
                table.insert(tab.contentDrawings, item.knob)
                table.insert(item.drawings, item.knob)
                
                -- Slider label
                item.label = Drawing.new("Text")
                item.label.Text = sliderText
                item.label.Position = item.bg.Position + Vector2.new(170, 11)
                item.label.Size = 14
                item.label.Color = Color3.fromRGB(255, 255, 255)
                item.label.Font = Drawing.Fonts.SystemBold
                item.label.Outline = true
                item.label.ZIndex = 8
                item.label.Visible = false
                table.insert(allDrawings, item.label)
                table.insert(tab.contentDrawings, item.label)
                table.insert(item.drawings, item.label)
                
                -- Value display
                item.valueText = Drawing.new("Text")
                item.valueText.Text = tostring(math.floor(item.value))
                item.valueText.Position = item.track.Position + Vector2.new(75, -10)
                item.valueText.Size = 12
                item.valueText.Color = Color3.fromRGB(255, 255, 255)
                item.valueText.Center = true
                item.valueText.Outline = true
                item.valueText.ZIndex = 8
                item.valueText.Visible = false
                table.insert(allDrawings, item.valueText)
                table.insert(tab.contentDrawings, item.valueText)
                table.insert(item.drawings, item.valueText)
                
                item.isSlider = true
                item.onSlide = callback
                
                function item:setValue(val)
                    self.value = math.clamp(val, self.min, self.max)
                    local percent = (self.value - self.min) / (self.max - self.min)
                    self.knob.Position = self.track.Position + Vector2.new(150 * percent - 10, -5)
                    self.valueText.Text = tostring(math.floor(self.value))
                    self.onSlide(self.value)
                end
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.track.Position = self.bg.Position + Vector2.new(7, 13)
                    local percent = (self.value - self.min) / (self.max - self.min)
                    self.knob.Position = self.track.Position + Vector2.new(150 * percent - 10, -5)
                    self.label.Position = self.bg.Position + Vector2.new(170, 11)
                    self.valueText.Position = self.track.Position + Vector2.new(75, -10)
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:Dropdown(dropText, options, callback)
                dropText = dropText or "Dropdown"
                options = options or {"Option 1", "Option 2"}
                callback = callback or function() end
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset,
                    isOpen = false,
                    options = options,
                    selected = options[1] or "None",
                    optionDrawings = {}
                }
                
                -- Dropdown background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- Dropdown button
                item.button = Drawing.new("Square")
                item.button.Position = item.bg.Position + Vector2.new(7, 3)
                item.button.Size = Vector2.new(150, 30)
                item.button.Color = Color3.fromRGB(255, 255, 255)
                item.button.Filled = true
                item.button.Corner = 8
                item.button.ZIndex = 8
                item.button.Visible = false
                table.insert(allDrawings, item.button)
                table.insert(tab.contentDrawings, item.button)
                table.insert(item.drawings, item.button)
                
                -- Selected text
                item.text = Drawing.new("Text")
                item.text.Text = item.selected
                item.text.Position = item.button.Position + Vector2.new(5, 7)
                item.text.Size = 16
                item.text.Color = Color3.fromRGB(0, 0, 0)
                item.text.Outline = true
                item.text.ZIndex = 9
                item.text.Visible = false
                table.insert(allDrawings, item.text)
                table.insert(tab.contentDrawings, item.text)
                table.insert(item.drawings, item.text)
                
                -- Arrow
                item.arrow = Drawing.new("Text")
                item.arrow.Text = "▼"
                item.arrow.Position = item.button.Position + Vector2.new(130, 7)
                item.arrow.Size = 13
                item.arrow.Color = Color3.fromRGB(0, 0, 0)
                item.arrow.Outline = true
                item.arrow.ZIndex = 9
                item.arrow.Visible = false
                table.insert(allDrawings, item.arrow)
                table.insert(tab.contentDrawings, item.arrow)
                table.insert(item.drawings, item.arrow)
                
                -- Label
                item.label = Drawing.new("Text")
                item.label.Text = dropText
                item.label.Position = item.bg.Position + Vector2.new(170, 11)
                item.label.Size = 14
                item.label.Color = Color3.fromRGB(255, 255, 255)
                item.label.Font = Drawing.Fonts.SystemBold
                item.label.Outline = true
                item.label.ZIndex = 8
                item.label.Visible = false
                table.insert(allDrawings, item.label)
                table.insert(tab.contentDrawings, item.label)
                table.insert(item.drawings, item.label)
                
                -- Create option elements
                for i, opt in ipairs(options) do
                    local optBg = Drawing.new("Square")
                    optBg.Position = item.button.Position + Vector2.new(0, 30 * i)
                    optBg.Size = Vector2.new(150, 30)
                    optBg.Color = Color3.fromRGB(51, 51, 51)
                    optBg.Filled = true
                    optBg.Corner = 8
                    optBg.ZIndex = 10
                    optBg.Visible = false
                    table.insert(allDrawings, optBg)
                    table.insert(tab.contentDrawings, optBg)
                    
                    local optText = Drawing.new("Text")
                    optText.Text = opt
                    optText.Position = optBg.Position + Vector2.new(5, 7)
                    optText.Size = 16
                    optText.Color = Color3.fromRGB(255, 255, 255)
                    optText.Outline = true
                    optText.ZIndex = 11
                    optText.Visible = false
                    table.insert(allDrawings, optText)
                    table.insert(tab.contentDrawings, optText)
                    
                    table.insert(item.optionDrawings, {bg = optBg, text = optText, value = opt})
                end
                
                item.isDropdown = true
                item.onSelect = callback
                
                function item:toggle()
                    self.isOpen = not self.isOpen
                    for _, opt in ipairs(self.optionDrawings) do
                        opt.bg.Visible = self.isOpen and visible and tab.visible
                        opt.text.Visible = self.isOpen and visible and tab.visible
                    end
                end
                
                function item:select(value)
                    self.selected = value
                    self.text.Text = value
                    self:toggle()
                    self.onSelect(value)
                end
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.button.Position = self.bg.Position + Vector2.new(7, 3)
                    self.text.Position = self.button.Position + Vector2.new(5, 7)
                    self.arrow.Position = self.button.Position + Vector2.new(130, 7)
                    self.label.Position = self.bg.Position + Vector2.new(170, 11)
                    
                    for i, opt in ipairs(self.optionDrawings) do
                        opt.bg.Position = self.button.Position + Vector2.new(0, 30 * i)
                        opt.text.Position = opt.bg.Position + Vector2.new(5, 7)
                    end
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:KeyBind(keyText, defaultKey, callback)
                keyText = keyText or "KeyBind"
                defaultKey = defaultKey or 45 -- Insert
                callback = callback or function() end
                
                local item = {
                    drawings = {},
                    height = 39,
                    yOffset = itemYOffset,
                    key = defaultKey,
                    listening = false
                }
                
                -- KeyBind background
                item.bg = Drawing.new("Square")
                item.bg.Position = section.frame.Position + Vector2.new(8, itemYOffset)
                item.bg.Size = Vector2.new(365, 36)
                item.bg.Color = Color3.fromRGB(18, 18, 18)
                item.bg.Filled = true
                item.bg.Corner = 3
                item.bg.ZIndex = 7
                item.bg.Visible = false
                table.insert(allDrawings, item.bg)
                table.insert(tab.contentDrawings, item.bg)
                table.insert(item.drawings, item.bg)
                
                -- KeyBind button
                item.button = Drawing.new("Square")
                item.button.Position = item.bg.Position + Vector2.new(7, 3)
                item.button.Size = Vector2.new(100, 30)
                item.button.Color = Color3.fromRGB(255, 255, 255)
                item.button.Filled = true
                item.button.ZIndex = 8
                item.button.Visible = false
                table.insert(allDrawings, item.button)
                table.insert(tab.contentDrawings, item.button)
                table.insert(item.drawings, item.button)
                
                -- Key text
                item.text = Drawing.new("Text")
                item.text.Text = "[ " .. getKeyName(defaultKey) .. " ]"
                item.text.Position = item.button.Position + Vector2.new(50, 15)
                item.text.Size = 16
                item.text.Color = Color3.fromRGB(0, 0, 0)
                item.text.Center = true
                item.text.Outline = true
                item.text.ZIndex = 9
                item.text.Visible = false
                table.insert(allDrawings, item.text)
                table.insert(tab.contentDrawings, item.text)
                table.insert(item.drawings, item.text)
                
                -- Label
                item.label = Drawing.new("Text")
                item.label.Text = keyText
                item.label.Position = item.bg.Position + Vector2.new(120, 11)
                item.label.Size = 14
                item.label.Color = Color3.fromRGB(255, 255, 255)
                item.label.Font = Drawing.Fonts.SystemBold
                item.label.Outline = true
                item.label.ZIndex = 8
                item.label.Visible = false
                table.insert(allDrawings, item.label)
                table.insert(tab.contentDrawings, item.label)
                table.insert(item.drawings, item.label)
                
                item.isKeybind = true
                item.onKey = callback
                
                function item:startListening()
                    self.listening = true
                    self.text.Text = "..."
                    self.text.Color = Color3.fromRGB(255, 255, 0)
                end
                
                function item:setKey(keyCode)
                    self.key = keyCode
                    self.text.Text = "[ " .. getKeyName(keyCode) .. " ]"
                    self.text.Color = Color3.fromRGB(0, 0, 0)
                    self.listening = false
                end
                
                function item:updatePositions(yOff)
                    self.yOffset = yOff
                    self.bg.Position = section.frame.Position + Vector2.new(8, yOff)
                    self.button.Position = self.bg.Position + Vector2.new(7, 3)
                    self.text.Position = self.button.Position + Vector2.new(50, 15)
                    self.label.Position = self.bg.Position + Vector2.new(120, 11)
                end
                
                itemYOffset = itemYOffset + 39
                table.insert(section.items, item)
                section:recalculateHeight()
            end
            
            function ItemHandling:TextBox(boxText, placeholder, callback)
                -- Simplified implementation
                ItemHandling:Label(boxText .. ": " .. (placeholder or ""))
            end
            
            function ItemHandling:Credit(creditText)
                ItemHandling:Label(creditText)
            end
            
            return ItemHandling
        end
        
        return SectionHandling
    end
    
    -- Main input loop
    spawn(function()
        while wait(0.01) do
            if isrbxactive() then
                local mouse1 = ismouse1pressed()
                local mPos = Vector2.new(Mouse.X, Mouse.Y)
                
                -- Handle toggle key listening
                if listeningForKey then
                    for i = 1, 255 do
                        if iskeypressed(i) and not mouse1 then
                            toggleKey = i
                            closeKeyText.Text = getKeyName(i)
                            listeningForKey = false
                            wait(0.2)
                            break
                        end
                    end
                else
                    -- Check toggle key
                    if iskeypressed(toggleKey) then
                        visible = not visible
                        for _, drawing in ipairs(allDrawings) do
                            drawing.Visible = visible
                        end
                        wait(0.2)
                    end
                end
                
                -- Mouse down
                if mouse1 and not lastMouse1 then
                    -- Check close key button
                    if isMouseOver(closeKeyBg.Position, closeKeyBg.Size, mPos) then
                        listeningForKey = true
                        closeKeyText.Text = "..."
                        closeKeyText.Color = Color3.fromRGB(255, 255, 0)
                    end
                    
                    -- Check if dragging window (click on side heading)
                    if isMouseOver(sideHeading.Position, Vector2.new(sideHeading.Size.X, 40), mPos) then
                        dragging = true
                        dragStart = mPos
                        dragOffset = basePos - mPos
                    end
                    
                    -- Check tabs
                    for _, tab in ipairs(tabs) do
                        if isMouseOver(tab.bg.Position, tab.bg.Size, mPos) then
                            tab:activate()
                        end
                    end
                    
                    -- Check current tab sections and items
                    if currentTab then
                        for _, section in ipairs(currentTab.sections) do
                            -- Check section header for expand/collapse
                            if isMouseOver(section.frame.Position, Vector2.new(section.frame.Size.X, 36), mPos) then
                                section:toggle()
                            end
                            
                            -- Check items
                            if section.expanded then
                                for _, item in ipairs(section.items) do
                                    if item.isButton and isMouseOver(item.bg.Position, item.bg.Size, mPos) then
                                        item.onClick()
                                    elseif item.isToggle and isMouseOver(item.bg.Position, item.bg.Size, mPos) then
                                        item:toggle()
                                    elseif item.isDropdown then
                                        if isMouseOver(item.button.Position, item.button.Size, mPos) then
                                            item:toggle()
                                        end
                                        if item.isOpen then
                                            for _, opt in ipairs(item.optionDrawings) do
                                                if isMouseOver(opt.bg.Position, opt.bg.Size, mPos) then
                                                    item:select(opt.value)
                                                end
                                            end
                                        end
                                    elseif item.isKeybind and isMouseOver(item.button.Position, item.button.Size, mPos) then
                                        item:startListening()
                                    elseif item.isSlider and isMouseOver(item.knob.Position, item.knob.Size, mPos) then
                                        item.isDragging = true
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Mouse up
                if not mouse1 and lastMouse1 then
                    dragging = false
                    if currentTab then
                        for _, section in ipairs(currentTab.sections) do
                            for _, item in ipairs(section.items) do
                                if item.isSlider then
                                    item.isDragging = false
                                end
                            end
                        end
                    end
                end
                
                -- Handle dragging
                if dragging and mouse1 then
                    basePos = mPos + dragOffset
                    updatePositions()
                end
                
                -- Handle slider dragging
                if currentTab then
                    for _, section in ipairs(currentTab.sections) do
                        for _, item in ipairs(section.items) do
                            if item.isSlider and item.isDragging and mouse1 then
                                local percent = math.clamp((mPos.X - item.track.Position.X) / 150, 0, 1)
                                local value = item.min + (item.max - item.min) * percent
                                item:setValue(value)
                            end
                        end
                    end
                end
                
                -- Handle keybind listening
                if currentTab then
                    for _, section in ipairs(currentTab.sections) do
                        for _, item in ipairs(section.items) do
                            if item.isKeybind and item.listening then
                                for i = 1, 255 do
                                    if iskeypressed(i) and not mouse1 then
                                        item:setKey(i)
                                        wait(0.2)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                lastMouse1 = mouse1
            end
        end
    end)
    
    return TabHandling
end

return Luxt1
