-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- hi, i'm Chris, and I wrote this UI interface for my exclaims mod with the assistance of Kekskruemelkittey.                                                        --
-- To contact me, my Discord is ''crystalchris'' for any questions or comments or concerns!                                                                          --            
--                                                                                                                                                                   --
--                                                                                                                                                                   --
--  ________      ________       ___    ___  ________       _________    ________      ___           ________      ___  ___      ________      ___      ________     -- 
--|\   ____\    |\   __  \     |\  \  /  /||\   ____\     |\___   ___\ |\   __  \    |\  \         |\   ____\    |\  \|\  \    |\   __  \    |\  \    |\   ____\     --
--\ \  \___|    \ \  \|\  \    \ \  \/  / /\ \  \___|_    \|___ \  \_| \ \  \|\  \   \ \  \        \ \  \___|    \ \  \\\  \   \ \  \|\  \   \ \  \   \ \  \___|_    --
-- \ \  \        \ \   _  _\    \ \    / /  \ \_____  \        \ \  \   \ \   __  \   \ \  \        \ \  \        \ \   __  \   \ \   _  _\   \ \  \   \ \_____  \   --
--  \ \  \____    \ \  \\  \|    \/  /  /    \|____|\  \        \ \  \   \ \  \ \  \   \ \  \____    \ \  \____    \ \  \ \  \   \ \  \\  \|   \ \  \   \|____|\  \  --
--   \ \_______\   \ \__\\ _\  __/  / /        ____\_\  \        \ \__\   \ \__\ \__\   \ \_______\   \ \_______\   \ \__\ \__\   \ \__\\ _\    \ \__\    ____\_\  \ --
--    \|_______|    \|__|\|__||\___/ /        |\_________\        \|__|    \|__|\|__|    \|_______|    \|_______|    \|__|\|__|    \|__|\|__|    \|__|   |\_________\--
--                            \|___|/         \|_________|                                                                                               \|_________|--
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local InvestigationUi = {}
InvestigationUi.Window = ISCollapsableWindowJoypad:derive("InvestigationUiWindow")

local uiWindow = nil

local CategoryTranslationKeys = {
    exclamations = "IGUI_TTRPDescriptors_Categories_Exclamations",
    questions    = "IGUI_TTRPDescriptors_Categories_Questions",
    shapes       = "IGUI_TTRPDescriptors_Categories_Shapes",
    pinnednotes  = "IGUI_TTRPDescriptors_Categories_PinnedNotes",
    propscenes   = "IGUI_TTRPDescriptors_Categories_propscenes",
    notadmin     = "IGUI_TTRPDescriptors_Categories_AdminShapes",
}

local CategoryIcons = {
    exclamations = "media/ui/ExclamationGrey.png",
    questions    = "media/ui/QuestionGrey.png",
    shapes       = "media/ui/XGrey.png",
    pinnednotes  = "media/ui/PinnedPaperKnife.png",
    propscenes   = "media/ui/MetalSignpost.png",
    notadmin     = "media/ui/ExclamationBlue.png",
}

local function isAdminUser(playerIndex)
    local player = getSpecificPlayer(playerIndex or 0)
    return player and isAdmin()
end

local function getIconForSubCategory(categoryKey, subKey)
    local texturePath = nil

    if categoryKey == "exclamations" then
        local color = subKey:match("Exclamation(.*)")
        if color then
            color = color:gsub("Floating", "")
            texturePath = "media/ui/Exclamation" .. color .. ".png"
        end

    elseif categoryKey == "questions" then
        local color = subKey:match("Question(.*)")
        if color then
            color = color:gsub("Floating", "")
            texturePath = "media/ui/Question" .. color .. ".png"
        end

    elseif categoryKey == "shapes" then
        local shapeType, color = subKey:match("([XO])(.*)")
        if shapeType and color then
            color = color:gsub("Floating", "")
            texturePath = "media/ui/" .. shapeType .. color .. ".png"
        end

    elseif categoryKey == "pinnednotes" or categoryKey == "notadmin" then
        local iconName = subKey
            :gsub("TTRPDescriptors%.", "")
            :gsub("Floating", "")
        texturePath = "media/ui/" .. iconName .. ".png"

    elseif categoryKey == "propscenes" then
        local item = InventoryItemFactory.CreateItem(subKey)
        if item then
            return item:getTex()
        end
    end

    if texturePath then
        local texture = getTexture(texturePath)
        if not texture then
            print("Warning: Missing texture for " .. texturePath)
        end
        return texture
    end

    return nil
end


function InvestigationUi.Window:new(x, y, width, height)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function InvestigationUi.Window:initialise()
    ISCollapsableWindowJoypad.initialise(self)
    self:setTitle("Investigation UI")
end

function InvestigationUi.Window:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local padding = 10
    local titleBarHeight = self:titleBarHeight()
    local categoryWidth = 150
    local subCategoryWidth = self.width - (padding * 3) - categoryWidth    
    local panelHeight = self.height - titleBarHeight - padding * 2

    -- Categories List
    self.categoriesList = ISScrollingListBox:new(padding, titleBarHeight + padding, categoryWidth, panelHeight)
    self.categoriesList:initialise()
    self.categoriesList:instantiate()
    self.categoriesList.itemheight = 35
    self.categoriesList.font = UIFont.Medium
    self.categoriesList.drawBorder = true
    self.categoriesList.doDrawItem = function(list, y, item, alt)
        list:drawRectBorder(0, y, list:getWidth(), list.itemheight - 1, 0.9, 1, 1, 1)
        if list.selected == item.index then
            list:drawRect(0, y, list:getWidth(), list.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
        end
        if item.item.iconTexture then
            list:drawTextureScaledAspect(item.item.iconTexture, 5, y + 5, 25, list.itemheight - 10, 1, 1, 1, 1)
        end
        list:drawText(item.text, 35, y + (list.itemheight - getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()) / 2, 1, 1, 1, 0.9, list.font)
        return y + list.itemheight
    end
    self.categoriesList.onMouseDown = function(listbox, x, y)
        local index = listbox:rowAt(x, y)
        if index and listbox.items[index] then
            listbox.selected = index
            local realCategoryKey = listbox.items[index].item.realKey
            self:populateSubCategories(realCategoryKey)
        end
    end
    self:addChild(self.categoriesList)

    -- Subcategories List
    self.subCategoriesList = ISScrollingListBox:new(self.categoriesList:getRight() + padding, titleBarHeight + padding, subCategoryWidth, panelHeight - 40)
    self.subCategoriesList:initialise()
    self.subCategoriesList:instantiate()
    self.subCategoriesList.itemheight = 35
    self.subCategoriesList.font = UIFont.Medium
    self.subCategoriesList.drawBorder = true
    self.subCategoriesList.doDrawItem = self.categoriesList.doDrawItem
    self.subCategoriesList.onMouseDown = function(listbox, x, y)
        local index = listbox:rowAt(x, y)
        if index and listbox.items[index] then
            listbox.selected = index
            self.selectedItemType = listbox.items[index].item.realKey
        end
    end
    self:addChild(self.subCategoriesList)

    -- Spawn Button
    self.spawnButton = ISButton:new(self.subCategoriesList.x, self.subCategoriesList:getBottom() + 5, 80, 25, "Spawn", self, InvestigationUi.Window.onSpawnButton)
    self.spawnButton:initialise()
    self.spawnButton:instantiate()
    self.spawnButton.borderColor.a = 0.7
    self:addChild(self.spawnButton)

    self:populateCategories()
    if #self.categoriesList.items > 0 then
        self.categoriesList.selected = 1
        self:populateSubCategories(self.categoriesList.items[1].item.realKey)
    end
end


function InvestigationUi.Window:populateCategories()
    self.categoriesList:clear()
    local wantedCategories = { "exclamations", "questions", "shapes", "propscenes", "pinnednotes", "notadmin" }
    local playerIndex = self.playerNum or 0
    local isAdmin = isAdminUser(playerIndex)

    for _, cat in ipairs(wantedCategories) do
        local allowCategory = true

        if not isAdmin then
            if cat == "questions" and not SandboxVars.TTRPDescriptors.ToggleQuestions then
                allowCategory = false
            elseif cat == "exclamations" and not SandboxVars.TTRPDescriptors.ToggleExclamations then
                allowCategory = false
            elseif cat == "pinnednotes" and not SandboxVars.TTRPDescriptors.TogglePinnedNotes then
                allowCategory = false
            elseif cat == "shapes" and not SandboxVars.TTRPDescriptors.ToggleShapes then
                allowCategory = false
            elseif cat == "propscenes" and not SandboxVars.TTRPDescriptors.ToggleProps then
                allowCategory = false
            elseif cat == "notadmin" and not SandboxVars.TTRPDescriptors.AllowNonAdminShapes then
                allowCategory = false
            end
        end

        if allowCategory and TTRPshapes[cat] then
            local translationKey = CategoryTranslationKeys[cat] or cat
            local displayName = getText(translationKey) or cat
            local texture = CategoryIcons[cat] and getTexture(CategoryIcons[cat]) or nil
            self.categoriesList:addItem(displayName, {
                realKey = cat,
                iconTexture = texture,
                tabName = cat
            })
        end
    end
end

function InvestigationUi.Window:populateSubCategories(categoryKey)
    self.subCategoriesList:clear()
    self.selectedItemType = nil

    local subTable = TTRPshapes[categoryKey]
    if subTable then
        local index = 1
        for key, _ in pairs(subTable) do
            local item = InventoryItemFactory.CreateItem(key)
            local displayName = item and item:getName() or key
            local texture = getIconForSubCategory(categoryKey, key)
            self.subCategoriesList:addItem(displayName, {
                realKey = key,
                iconTexture = texture,
                tabName = categoryKey
            })
        end

        if #self.subCategoriesList.items > 0 then
            self.subCategoriesList.selected = 1
            self.selectedItemType = self.subCategoriesList.items[1].item.realKey
        end
    end
end


function InvestigationUi.Window:onResize()
    ISCollapsableWindowJoypad.onResize(self)

    local padding = 10
    local titleBarHeight = self:titleBarHeight()
    local panelHeight = self.height - titleBarHeight - (padding * 2)
    local categoryWidth = 250
    local subCategoryWidth = self.width - (padding * 3) - categoryWidth

    self.categoriesList:setX(padding)
    self.categoriesList:setY(titleBarHeight + padding)
    self.categoriesList:setWidth(categoryWidth)
    self.categoriesList:setHeight(panelHeight)

    self.subCategoriesList:setX(self.categoriesList:getRight() + padding)
    self.subCategoriesList:setY(titleBarHeight + padding)
    self.subCategoriesList:setWidth(subCategoryWidth)
    self.subCategoriesList:setHeight(panelHeight - 40)

    self.spawnButton:setX(self.subCategoriesList.x)
    self.spawnButton:setY(self.subCategoriesList:getBottom() + 5)
end


function InvestigationUi.open(player)
    if uiWindow and uiWindow:isReallyVisible() then return end
    local width, height = 800, 600
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2
    uiWindow = InvestigationUi.Window:new(x, y, width, height)
    uiWindow:initialise()
    uiWindow:addToUIManager()
end

function InvestigationUi.Window:onSpawnButton()
    if not self.selectedItemType then return end
    local playerIndex = self.playerNum or 0
    TTRPshapes.onCreateScene(true, playerIndex, self.selectedItemType)
end

function OpenInvestigationUI()
    InvestigationUi.open(getSpecificPlayer(0))
end

-- Debug keybind.
-- Events.OnKeyPressed.Add(function(key)
--   if key == 74 then
--       OpenInvestigationUI()
--   end
--end)

return InvestigationUi

-- ⣿⣿⣿⢿⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⣿⣻⣟⡿⣽⣻⡽⢯⡿⣽⣫⡟⣽⣫⢟⣽⢫⡟⣽⢫⡟⣭⡻⣭⢻⡭⢯⡽⣭⢯⡽⣭⠻⣜⡣⢟⣜⡣⢟⡜⣣⢛⡜⣣⢛⡜⣣⢏⡼⣡⢏⡼⣡⢏⡼⣡⢏⡼⡱
-- ⣿⣷⣻⣟⣾⣳⢿⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⡷⣯⣟⡷⣯⡽⣯⢷⣏⡷⣽⣣⢯⣟⢮⣯⢽⣚⡷⣹⢧⣻⡜⣧⣛⢧⡻⣜⢮⡳⣭⢻⡔⣏⡳⢎⡝⢮⠼⣱⢫⠼⣱⢫⡜⡱⢎⠶⡱⢎⠶⡱⢎⠶⡱⢎⠶⣙
-- ⣿⢿⣽⡾⣷⣟⣯⢿⡾⣽⣻⢾⣽⣻⢾⣽⣻⢾⣽⣻⣞⣯⣟⣾⣳⣟⣾⣳⣟⣾⣳⣟⣾⣳⣟⣾⣳⣟⣾⣽⣻⢾⣽⣻⢾⣽⢾⣯⢷⣟⣾⣳⣟⣾⣳⣟⣾⣳⣟⣾⣳⢯⣟⡷⢯⣟⡷⣻⣵⡻⣾⣱⢷⣫⠷⣞⢯⡞⣧⢟⡼⣏⢷⣣⢟⡵⣫⢞⡽⣎⢷⡹⣞⢣⡞⣱⢭⡛⡼⣙⡞⣥⣋⢗⣣⠳⣜⡹⢎⡳⣙⢎⡳⣙⢎⡳⣙⢮⡹⣒
-- ⣿⣯⣷⢿⣳⣯⣟⣯⡿⣽⢯⣿⢾⣽⣻⢾⣽⣻⣞⡷⣯⢷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⢯⣷⣟⡿⣞⡿⣞⣯⡿⣞⣷⣻⣞⣷⣻⣞⣷⣻⣾⣽⣿⣾⣿⣿⣾⣿⣷⣿⣷⣯⣟⣾⣭⢿⡹⣾⣹⢮⣏⢷⣫⢞⡵⣫⢷⡹⣎⢷⡹⣎⠷⡭⢮⡕⣏⠶⣹⢱⢣⠞⡴⣩⠞⡴⣋⠶⣙⢮⡱⣍⢮⡱⣍⢮⡱⡍⢶⣑⢣
-- ⣿⡾⣽⡿⣽⡾⣽⣳⡿⣯⣟⣾⣻⢾⣽⣻⣞⡷⣯⢿⡽⣯⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⢾⡽⣟⣾⣽⣻⡽⣟⣯⣷⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣧⣛⡾⣼⢣⡟⣮⢳⡝⣮⢳⡝⣮⠳⣭⢛⡼⢣⢞⡬⡳⣍⢎⢧⡛⡴⢣⡛⡴⣍⢞⡱⢎⡵⣊⠶⡱⢎⡖⣱⡙⢦⡍⡖
-- ⣿⣻⣽⣟⡷⣟⣯⡷⣟⡷⣯⢷⣻⣟⣾⣳⢯⡿⣽⢯⣟⡷⣯⢷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⢾⡽⣯⣟⣯⡷⣯⣷⣟⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣵⣫⢞⡵⣏⢾⡱⢯⡞⡵⣛⢦⣛⡼⣍⠾⣰⠳⡜⣎⠶⡹⣜⢣⡝⡲⣍⢮⡱⢫⠴⣩⠞⣡⠳⡜⡥⣚⢥⡚⡜
-- ⣿⣽⣳⣯⣟⣯⡷⣟⣯⢿⡽⣯⢷⣻⢾⡽⣯⢿⣽⣻⢾⣽⣻⢯⣷⣻⣞⣷⣻⣞⣷⣻⣞⣷⣻⢾⡽⣯⢿⡽⣞⣯⢿⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⡽⢮⡝⣧⡛⣵⡩⢖⣣⠞⣬⠳⣥⢛⡼⣌⢳⡱⢎⢧⡚⡵⣊⠶⣉⢧⢛⡤⣛⠴⣋⠼⡱⡜⣆⢧⡙
-- ⣿⢾⣽⡾⣽⣳⣟⣯⣟⣯⢿⡽⣯⣟⣯⢿⣽⣻⢾⣽⣻⢾⣽⣻⡞⣷⣻⣞⣷⣻⣞⣷⣻⢾⡽⣯⢿⡽⣯⣟⣯⣟⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣣⢟⠶⣙⢦⡛⡵⢪⡝⢦⡛⡴⣋⠶⣩⢖⡹⢎⠶⡹⠴⣩⠞⡱⢎⡣⠞⡴⢋⡼⣡⠣⡵⣈⠦⣙
-- ⣿⢯⣷⣟⣯⡷⣯⣷⣻⣞⣯⣟⣷⣻⣞⡿⣾⣽⣻⢾⡽⣻⡞⣷⡻⢷⣛⣾⣳⣟⣾⣳⣯⡿⣽⢯⡿⣽⣳⣟⡾⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣟⣿⢻⡽⢺⡝⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣎⢯⡹⣆⠻⣜⢣⠞⣥⢛⡴⣩⢞⡱⢎⡵⢋⡞⣱⢋⠶⣉⠷⡩⢞⡱⣘⠣⢖⡡⢓⡴⣉⠖⣡
-- ⣿⣻⢷⣻⡾⣽⢷⣯⢷⣻⢾⡽⣞⡷⣯⣟⣷⣳⢯⣟⢾⣳⢟⣳⣟⣯⣟⣾⣳⡽⣞⡷⣯⢿⡽⣯⣟⣷⣻⣞⣿⣿⣿⡟⢥⠲⡝⣾⣟⣿⣿⣻⣿⣟⣿⣯⢿⣞⣷⣻⣽⣚⠷⣘⢧⡚⡕⢦⢫⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣲⢣⡭⢳⢬⢣⡛⡴⣋⠶⡱⢎⡵⢋⡜⣣⠞⡥⢫⡜⡱⢎⡱⢎⠴⢣⡙⢦⡙⢦⠱⣌⠚⡤
-- ⣿⣽⣻⢷⣻⢯⣟⡾⣯⣟⣯⢿⣽⣻⢷⣻⢮⣽⣳⢯⣻⣭⡟⣷⣞⣳⣞⡷⣯⢿⡽⣽⣏⣯⣟⣷⣻⣞⣷⣻⣿⣿⠫⠄⣉⣳⣽⣼⣿⣿⣿⢿⣟⣿⢯⣟⡿⣞⣷⡳⢞⡜⢢⠏⡖⡩⢞⡥⣛⣞⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢣⢞⡱⢎⢧⡙⢶⡩⢞⡱⣋⠶⣩⠞⣡⠞⣱⠣⡜⡱⢊⠖⡩⢎⡱⡘⠦⡑⢎⡱⢌⡓⡔
-- ⣿⢾⣽⣻⣯⢿⣽⣻⢷⣻⣞⣯⢷⡯⣟⣞⡿⣼⢏⣯⢷⣳⣻⣳⣞⢷⣫⣟⡷⣯⣟⢷⣻⢮⡽⣞⣷⡻⣞⣿⣿⠁⠳⢾⣧⣽⣞⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⡿⣿⡝⣮⢞⡳⣎⠳⡵⢊⡴⢻⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢮⠳⣍⠶⣙⢦⡙⣎⠵⣊⠗⡱⢎⡱⣊⠥⡓⣬⢱⡉⢎⡱⢊⠴⣡⠣⣙⠢⡑⠦⡱⢌
-- ⣿⢯⣟⡷⣯⣟⣾⡽⣯⢷⣻⣞⣯⣽⣻⣼⣛⣾⣛⡾⣏⡷⣏⡷⣞⣯⢷⢯⡽⣶⢯⣛⣧⢿⡽⣳⢾⣽⣻⣿⠃⢉⡷⣿⣹⢯⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣯⡿⣯⢟⡞⣞⡳⣜⣫⡑⠳⠾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢌⡳⢬⢳⡩⢖⡹⡸⡜⡡⢏⡕⢎⡱⣉⠖⡱⢢⠱⡘⠦⡑⣍⠲⢄⠳⣄⢣⡙⢆⡱⢊
-- ⣿⣯⢿⡽⣷⣻⣞⡿⣽⢯⣷⣻⢮⢷⣳⣳⠿⣜⣯⢷⣏⡿⣽⣹⢯⣞⣯⢯⣟⡾⣽⣛⣾⣫⡽⢯⣷⣫⣿⡟⢠⣯⣄⢿⣿⣿⣿⡧⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡱⢦⡝⢳⡒⠦⡄⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣎⡱⣋⠶⣙⢎⡵⢱⠱⣙⠲⡘⢎⡱⢌⢎⡑⢣⠱⣡⢣⡑⠦⡙⣌⢃⢆⠣⡜⠢⣅⠣
-- ⣿⣞⣿⡽⣷⢯⡿⣽⣻⣟⡶⣯⢟⣯⣗⡯⣿⠽⣞⣯⢾⣝⡧⣟⡧⢿⣜⡯⢾⡽⣞⡽⣶⢏⣿⣛⡶⣯⣿⠇⠿⢱⣿⢸⣿⣿⣡⣷⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣎⠧⡝⢲⠱⣌⡠⢘⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠳⣍⢞⡱⢎⠴⣋⢜⣢⡙⡱⢣⠜⡌⠦⣙⢂⠳⡐⠦⣑⢣⠱⡌⠎⡜⢢⡑⢣⠆⢣
-- ⣿⡾⣽⣻⡽⣯⣟⣷⣻⠾⣝⣳⣟⣞⡾⣽⢞⡿⣽⣺⣝⣮⡽⣞⡽⣏⡾⣝⣯⠾⣽⣹⢞⣟⣮⢿⣱⢯⣿⠀⣐⡊⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣜⢣⠷⢤⡡⠉⠆⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡎⡵⣊⢮⡱⢍⡲⢩⡒⢤⢣⡑⢣⠚⢬⡑⢢⢍⠲⣉⠖⡡⢎⠱⡘⡜⣠⠣⣘⢂⢎⡡
-- ⣿⡽⣷⢯⣟⣷⣻⢾⣽⣻⡽⣳⢾⣝⡾⣭⢿⣹⢧⢷⢾⣱⡟⡾⣵⢏⣷⢻⡼⣻⡵⢯⣾⣹⢮⣯⣻⣿⣧⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣶⣭⡞⢣⢏⣬⡱⡌⢒⡠⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡜⢲⠍⣦⠱⡎⡜⣡⠚⡔⢢⡙⢢⡙⢦⡘⢥⢊⠵⡨⠜⡐⢎⠱⡐⢆⡡⢒⡡⢊⠴⡐
-- ⣿⣳⣟⡾⣽⢯⣟⡾⣽⣫⢷⣻⣞⣽⣳⣛⣞⢯⣞⠾⣼⢏⣷⡳⡽⣞⡽⣞⢧⡿⣱⠾⣭⡟⡾⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠾⢞⡩⣇⠣⠌⡑⢺⣿⣿⣿⣿⣿⣿⣿⣿⢟⣿⣿⣿⡑⢎⡴⢩⡒⢥⠣⣍⠲⣑⠪⡑⢎⡱⢨⠱⡌⢚⠤⢃⠲⡑⡌⢆⠓⡌⢃⠎⡱⠘⡄⢣
-- ⣿⡽⣞⡿⣽⣻⢾⣽⣳⢯⣟⡵⣞⣧⢷⡻⣼⢏⣾⢻⡽⣺⢧⢿⣹⢾⣹⡞⣯⠾⣝⡯⣗⢿⡿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣖⣿⢯⢀⢒⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡶⡷⣎⠷⣤⢓⡒⣩⢒⣿⣿⣿⣿⡟⡹⠋⢴⣆⡘⣿⣷⣏⢲⡘⢥⡙⢆⠳⣨⠱⠌⡥⣙⠢⣅⠣⢃⠍⡆⠣⠍⠦⡑⠌⡌⠱⡈⠆⡜⢠⠃⡜⢠
-- ⣿⡽⣯⣟⡷⣯⣟⡾⣵⣻⠾⣽⣻⡼⣳⢏⣷⢻⢮⣏⡷⣏⢿⡺⣽⣚⣧⢟⣧⢿⣹⢾⣹⢾⣹⢟⡿⢥⣼⣿⣿⣿⣿⣿⣿⣿⣿⢳⠚⡼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣭⡛⠿⡵⣉⠞⣩⠳⢦⡀⢎⣽⣿⣿⣿⣇⢠⣅⠮⠿⢿⠿⣿⣗⠦⣙⢢⡙⣌⠳⣄⠫⡜⡰⢡⠣⡔⢩⢊⠜⡰⢩⠘⡰⢁⠞⡄⢣⠑⡌⠔⡡⢊⠔⡡
-- ⣿⣽⣳⣯⣟⡷⣯⣟⣳⣽⢻⣳⣭⠷⣏⣟⡮⣟⡽⢮⣗⢯⡯⢷⡳⣏⣾⢫⣞⣳⢯⢾⣹⡞⣽⡞⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡭⣇⡋⡔⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⢮⡓⢦⡙⣷⡳⣬⣦⢥⡛⣤⡙⣦⣿⣿⣿⣿⣏⣿⢸⣿⣿⣿⣿⣾⣿⡜⣌⠣⣜⠰⢣⢌⡱⢢⢙⣂⠳⢌⡡⠎⢆⡑⢢⠡⡑⢊⠴⡈⢆⠱⣈⠒⡡⠎⡰⢁
-- ⣿⣞⣷⣻⢾⣽⣳⢯⣷⢫⣯⢷⣚⣯⡽⣞⡵⣯⢽⡻⣼⣛⠾⣯⢽⡳⣽⢻⡼⣽⡺⣏⡷⣽⢣⣟⡞⣿⣾⣥⣿⣿⣿⣯⣿⡳⢷⡈⡑⠌⢠⡸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡽⣶⣍⢏⡞⣴⣙⣦⡹⢆⣿⣴⣽⣾⣿⣿⣿⣿⠐⡻⢷⢩⣿⣿⣿⣿⣿⡗⣨⠱⣌⠹⣂⠎⡔⢣⢌⠢⢃⠆⢢⠍⢢⠘⡄⢣⠘⣐⠢⡑⢌⠢⡁⢎⠰⡁⢆⠡
-- ⣿⢾⣳⣯⢿⡾⣽⣻⣼⣻⢞⣽⣹⢶⣻⢼⣻⢼⣳⡻⣵⣫⢟⡮⣗⣻⡼⣳⡽⣖⣻⡝⣾⡱⣟⢮⣽⡟⢻⣿⣿⣿⣟⣿⣯⢳⣦⣷⣶⣿⣿⢿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣼⣆⢳⣎⠿⣖⣾⣿⣾⣿⣿⣿⣿⣿⡀⣟⢈⣦⣹⣿⣿⢿⣿⠓⡤⢓⣌⢣⠱⡊⢜⡂⢎⡱⢊⡜⢄⠚⡄⢣⠘⡄⢃⠆⡱⢈⠆⡱⢈⠆⡱⢈⠄⡃
-- ⣿⢯⣟⡾⣯⣟⡷⣯⢶⣏⣟⡮⣗⣻⡼⣏⡾⡽⢶⡻⣵⢫⣾⡹⣞⡵⣫⢷⣹⢞⡵⣻⢖⣻⡝⣾⣿⠁⠰⠟⣿⣯⢸⣿⣯⡧⣴⣠⣴⣶⣦⣄⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⢿⣿⣿⣮⣷⣾⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣟⠃⢿⣿⠟⣽⣿⣿⠣⡙⡔⢣⠜⣢⠣⢍⠢⡙⢄⢢⠡⡘⢄⠣⡘⢄⠣⡘⢄⠊⡄⠣⡐⢄⠃⡔⢠⠃⡌⡐
-- ⣿⢯⡿⣽⣻⢾⡽⢯⡷⣞⢧⣟⣭⠷⣝⡾⣱⠿⣭⢗⣯⢳⡞⣵⡻⣼⣛⢮⡗⣯⡝⣧⡟⣧⢻⡞⣿⠀⠀⣦⣿⣿⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣹⢯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⣛⣷⠿⣫⣾⢃⠧⡱⡘⢥⠚⣄⠳⣈⠱⡈⢆⠢⡑⢌⠢⡑⢌⠢⡑⠰⡈⢆⠡⢃⠌⡂⠜⡠⢂⠅⢢⠁
-- ⣿⢯⣿⣳⣟⣯⣟⣯⠷⣏⡿⡼⣞⢯⣻⠼⣏⣟⢮⣻⡜⣯⢞⣳⡽⣣⢯⣳⢻⡼⣽⢲⡟⣼⡳⣏⢿⣆⠀⢿⣿⣿⣿⣯⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠶⢟⣿⢅⠺⡰⢡⡙⠤⢋⠤⠓⡄⢣⠘⡄⢣⠘⡄⢣⠘⠤⡑⢨⠑⠌⡄⢃⠢⡘⠄⡃⠔⣁⠊⡄⢃
-- ⣿⣻⣞⡷⣿⢮⡽⣞⣿⡹⣞⡽⣞⢯⣳⢻⡝⣮⢟⡶⣻⡝⣞⣧⢻⡵⣫⣗⢯⣳⡭⢷⣫⢷⡹⣎⡯⢿⣆⠘⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⢀⢻⡯⢌⢣⡑⢧⠘⡥⢋⠌⡓⢌⠢⡑⢌⠢⡑⢌⠢⢉⠆⢡⠂⡜⡐⢌⠂⡅⠢⡑⠌⢒⡀⠣⠌⡄
-- ⣿⣳⢯⡿⣽⣏⡿⣽⣲⢟⡽⣞⣭⢷⣫⢟⡼⣏⡾⣳⢧⣛⢷⡺⣝⡾⡵⣞⢯⡖⣯⡳⣝⡮⢷⡹⣞⣻⣿⡄⣿⣿⣿⡟⢛⣫⣿⣿⣿⣿⣿⣿⠟⣿⠛⢿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣹⡟⣌⠲⣡⠊⡕⢢⠡⢚⠰⡈⠖⡡⢊⠔⠡⢂⠱⡈⢌⠂⡅⢒⡈⢄⠣⡐⢡⠂⢍⠂⡌⢡⠒⠠
-- ⣿⡽⣯⣟⡷⣯⢷⣳⡽⢾⣹⡞⡽⣎⡷⣫⡽⣞⡵⣛⣮⢟⣮⢽⣣⢟⣵⢫⡾⣹⢖⣯⢳⡝⣧⢻⡜⣷⣿⣿⣿⣿⣿⣴⣿⡿⡏⢻⣿⣟⣤⣽⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠠⢚⡯⣐⠣⢆⠹⣠⢃⠣⢌⠢⡑⠌⠴⢁⢊⠱⡈⢆⠘⡠⢃⡘⢄⡘⢄⠢⢑⢂⠩⢄⠊⡔⠡⠌⡡
-- ⣿⣽⣳⣯⣟⣷⣛⣶⢻⡝⣧⡻⣝⢾⣱⣏⢷⣹⢞⡽⣎⢿⡜⣧⣛⠾⣜⢯⣳⣛⠾⣜⢧⡻⣜⢧⡻⣜⣿⣿⣿⣿⣿⣿⡟⠳⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠌⡐⢫⢄⠫⡜⢠⢃⠌⡒⢌⠢⢑⠊⡄⠣⢌⠰⡐⡈⢆⠡⢂⠔⡂⠔⡈⢆⠡⢊⠰⡈⠒⢄⠣⡘⠠
-- ⣿⣞⣷⣻⣞⡾⣝⡾⢯⣽⢺⡵⣏⡟⣶⡹⣞⡽⣚⡷⣹⢮⡻⣵⢫⡟⡽⣎⠷⣭⣛⢮⡳⣝⢮⡳⣝⡞⡶⣿⣿⣿⣿⡿⠈⢀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠬⣙⠆⢳⠘⠤⣉⠆⡱⢈⢆⠡⢊⠰⡁⢆⠡⢂⠱⣀⠣⠌⢒⡈⢆⠡⢂⠱⡈⠤⢡⠉⡂⢆⠡⡁
-- ⣿⢾⣽⣳⢯⣟⡽⣞⡿⣜⣳⡽⣺⡝⣶⢫⢷⡹⣝⠾⣭⣳⢻⣜⡳⣽⢳⣭⣛⢶⣭⢳⡝⣮⢳⡝⣮⣝⡳⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⡈⠴⣈⢏⠰⣉⠒⡡⢊⠔⡡⢈⠆⡡⢒⠈⡔⡈⢆⠡⡐⢂⡑⠢⡐⢂⠅⡊⠔⡠⢃⠢⡑⠨⠄⡃⠔
-- ⣿⣻⢾⣽⣳⢾⣹⣳⢽⡺⣵⢫⢷⡹⣞⡽⢮⣽⣚⢯⣳⢭⣳⢭⣳⢭⣳⢮⡝⡾⣜⢧⡻⣜⢧⡻⢶⣭⢳⢧⣿⣿⣿⣿⣿⣿⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⡐⢈⠲⢡⢎⡱⢄⡩⢐⠡⢊⠄⣃⠰⢁⠢⡑⠰⡈⢄⠃⡔⣁⠢⡑⢄⠃⡌⠰⣁⠒⡄⢃⠌⡑⢌⠰⢁
-- ⣿⣽⣻⢾⡽⣞⣧⢟⣞⣳⡭⣟⢮⢷⡹⣞⣳⢮⡝⣾⣱⢻⡜⣧⣛⢮⡳⣏⢾⣱⢏⡾⣱⢏⡾⣹⢳⣎⡟⡾⣴⢛⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠭⡀⢡⠌⡡⢂⡅⢺⡔⡨⢔⡡⢊⡅⢒⠠⡑⣈⠒⡈⢅⠒⣈⠒⡐⢄⠒⡨⠐⡌⠰⣁⢂⠒⡈⢆⡘⠰⢈⠢⢁
-- ⣿⢾⡽⣯⢷⣻⢮⣛⣮⢳⣝⣮⣛⢮⢷⡹⣎⢷⣹⠶⣭⣳⣛⠶⣭⡳⣝⡞⣧⣛⢮⣳⡝⣮⢳⣝⡳⢮⣝⡳⣯⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢻⡁⠞⡌⠐⡤⠂⠤⢡⠘⣐⠣⣏⡐⠆⡔⣡⠈⡆⡑⠰⣀⠃⡜⢠⢊⡐⢌⠰⣈⠂⡅⢃⠌⡡⢐⢂⠱⢈⠆⢌⠡⢊⠄⠡
-- ⡿⣯⣟⡷⢯⢷⣫⠷⣭⢷⣚⢶⡹⢮⡳⣝⢮⣳⢭⣛⢶⣣⢏⡟⡶⣝⢮⣝⠶⣭⡳⢧⣻⣜⡳⢮⣝⡳⢮⣽⣟⣩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣍⡳⢍⢦⣹⡰⢬⠑⡠⠨⠰⢀⣋⠄⠳⣼⡄⣙⠰⢠⡘⠤⣁⠣⡐⢌⡐⢢⠐⡰⢈⠢⠄⡃⠔⣈⠢⠑⡂⢌⠢⡁⢎⠠⠃⡄⢊⠐
-- ⣿⢷⣯⣟⢯⢷⣫⣟⢮⣳⡝⣮⣛⢧⣛⢮⡳⣝⡮⣝⣮⢳⣏⣞⡳⣝⠾⣜⡻⢶⣹⢳⡳⢮⣝⡳⢮⣝⡳⣞⢿⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣭⢻⣌⠳⣭⢖⣦⠳⣌⢌⠡⢁⠒⢡⠈⢎⠡⠜⣷⡈⠜⣠⠘⡰⢀⢣⠘⡄⠒⡄⢣⠐⡡⢂⠱⢈⠒⡠⢁⠣⢘⠠⢂⠅⢊⠐⠡⠐⠂⠌
-- ⣿⣻⢶⢯⣛⡾⡵⣞⢯⢶⡹⣖⢯⡞⣭⣳⢻⣜⡳⣝⢮⡳⣞⡼⣳⢭⣛⣮⡝⣧⢏⡷⣹⢳⢮⣝⡳⣎⠷⣭⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢯⣽⣳⢮⡳⣎⡳⡼⡞⡴⢫⡜⠌⢦⠉⠈⠄⡐⠂⡜⢨⢽⣿⡔⢂⠱⣀⠃⢆⠱⣈⠱⡈⢆⠱⣀⠣⡘⢄⠣⡐⢡⠊⡄⠣⢌⠘⡀⢊⠡⠌⠡⢈
-- ⣟⡷⢯⣟⡽⣺⣝⢾⡹⣎⢷⡹⢮⣝⠶⣭⡳⢮⣝⢮⡳⣝⢮⡳⣝⢮⣳⢮⣝⢮⡻⡼⣭⣛⠾⣜⡳⣭⣛⠶⣭⢿⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣏⣟⡳⢞⡥⢯⡽⣭⢳⢧⡹⢜⣣⡙⢾⡀⠎⠡⠀⢄⠡⡀⠣⢎⢿⣿⣧⣖⡠⢉⠆⡒⠤⡑⡈⢆⠱⣀⠣⡘⢄⠣⡘⢄⠣⡘⠰⡈⠆⡁⠢⠐⡈⢂⠁
-- ⣯⣟⣟⣮⡽⣳⢞⣯⢳⡝⣮⢽⡳⣎⡟⡶⣝⢯⡞⣧⣛⢮⢷⡹⣞⢧⣛⠾⣜⢧⡻⣵⢣⣏⠿⣜⡳⢧⣏⠿⣜⡧⣏⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣟⢾⡸⣹⡍⣞⣱⠞⣥⢻⢦⡙⣦⠧⡙⢦⡑⢎⠡⡀⠆⠰⢀⢣⠘⡼⣷⣏⡿⣿⣶⣾⣤⣵⣠⡑⣈⠒⠤⢑⠰⡈⢆⠱⡈⢆⠡⢃⠜⡠⠑⣂⠑⡠⠁⠌
-- ⣷⣻⡼⢶⣻⢵⣫⢞⣧⢻⡜⣧⢻⡼⣹⢳⡝⣮⡝⡶⣭⣛⢮⣳⡝⣮⣝⡻⣜⢧⡻⣜⡳⣞⡽⢮⣝⡳⣎⠿⣜⡳⣝⠾⣭⣛⠿⡿⢿⠿⣿⢿⣿⠋⠛⠛⠿⣿⣿⣿⣿⣿⣿⣿⣞⡧⢷⡩⡜⠶⣥⢯⡙⣧⣾⠵⣣⠝⣌⠣⡜⢢⠡⡁⠂⠅⣂⠢⠘⢤⢫⡝⣻⣷⣻⢞⣽⣻⣟⣿⡿⣿⣶⣮⣴⣡⣈⠆⡑⠌⢢⠁⢎⡐⠡⡀⠎⢠⢁⠂
-- ⣷⣳⢻⣏⣞⢧⣛⡾⣜⢧⡻⣜⣧⢻⡵⣫⢾⡱⣏⢷⣣⢟⣮⢳⡝⡶⣭⢳⡝⣮⢳⣭⢳⡝⣞⡳⢮⡝⣾⡹⢧⡻⣜⡻⢶⡍⡷⣍⣛⠮⡵⢎⣽⠀⠀⠀⠀⢮⣿⣿⣿⣿⣿⣿⡿⡞⣥⢳⡉⢳⡜⣦⢿⡻⣌⠷⣢⠝⣠⠒⡌⢠⠃⡔⢁⠂⠴⢈⡑⢎⡳⢼⢯⡷⣯⣟⣮⢷⣻⣾⣟⡿⣽⣿⣻⣿⣿⣿⣷⣾⣤⣉⡤⠘⢠⠁⡌⠂⡄⢂
-- ⡷⢯⣛⣞⢮⡻⣜⡳⣝⢮⢷⡹⣎⢷⡹⢧⣏⢷⡹⣎⢷⣫⢞⣧⢻⡵⣫⢷⡹⣎⢷⡺⣝⠾⣱⢏⡳⣝⢶⣹⢳⡝⣧⣛⢧⠞⡵⢎⢧⡛⣜⢣⢾⡃⠀⠀⠀⠠⣼⣿⣿⣿⣿⣟⣷⡻⣬⢓⣌⠶⣹⣯⣗⣳⣭⠳⡆⣍⠲⠠⠄⠃⡜⠐⡌⡀⢂⠬⠑⡎⡵⢋⡞⣹⢳⣻⣾⣿⢿⣟⣾⣟⣷⣿⣿⣽⣷⡿⣯⣿⣿⣿⣿⣿⣦⣴⣀⠡⠐⠂
-- ⣟⢯⡽⣎⣯⢳⡭⣗⢯⡞⣧⢻⡜⣯⣝⡳⢮⣏⢷⡹⣎⢷⣫⢞⣧⢻⡵⣫⢷⡹⣎⠷⣭⢻⡥⣏⢷⡹⣎⢷⣫⢞⡵⣭⠺⡭⣝⢮⢣⡝⣬⠓⡾⡇⠀⠀⠀⠐⢼⣽⣿⣿⣿⣿⣷⣿⠶⣏⢬⣛⣷⣻⣞⡷⣊⠷⣉⠦⣁⠣⣘⠐⡈⠱⣀⠖⠡⠀⡝⡘⡔⠫⡔⢣⡞⣿⣿⣿⣿⣿⣿⣾⣿⣿⣾⣿⣾⢿⣟⣷⡿⣯⣿⣿⢿⣿⣿⣿⣾⣤
-- ⣯⣛⢾⡱⣏⢷⡹⣎⢷⡹⣎⢷⣛⠶⣭⣛⠷⣎⢯⡳⡽⣎⢷⣫⢞⣧⢻⡵⣫⠷⣭⢻⡜⣧⢳⡝⣎⢷⡹⣎⢷⣋⠾⣜⢫⡵⣚⡬⢳⡜⢦⡛⡴⣧⠀⠀⠀⠀⠀⢙⣿⣿⣿⣿⣿⣯⡿⣜⡶⣹⣾⢯⣟⣳⡽⢎⡕⢢⠰⣁⠣⡜⢀⠡⡘⢠⠁⢆⠐⡤⢩⠓⣬⢓⡞⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣯⣿⣻⣿⣿
-- ⡷⣭⡗⣯⠽⣎⢷⣫⢞⡵⣫⡞⣭⣛⠶⣭⢻⡼⣣⢟⡵⣫⢞⡵⣫⢞⣧⢻⡵⣻⡜⣧⢻⣜⡳⢞⡭⡞⣵⢫⡞⣭⢻⢬⡳⣜⡱⢺⡱⢎⢧⡙⡖⣿⠀⠐⠄⢀⠀⠀⠉⣿⣿⣿⣿⣿⣟⡷⣏⣷⣿⣿⢿⣻⡝⢮⡜⣡⠓⠬⣑⠜⣨⠂⡁⢃⡚⢤⡈⢠⢃⡝⢦⣛⡾⣽⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣽⣿⣽⣿
-- ⣟⡵⣻⣜⡻⣜⢧⣛⢮⡳⢧⡻⣵⢫⡟⡼⢧⡻⣵⢫⡞⣵⢫⡞⣵⢫⡞⣧⣛⢶⡹⣎⢷⣪⠽⣹⢼⣙⢮⣳⢹⡜⣣⢳⣙⠦⣝⢣⡝⢎⢶⣭⡿⠛⠀⠀⠀⢹⠆⣄⣀⠿⣿⣿⣿⣿⣯⣿⡽⣾⣿⣯⡿⣧⣛⢧⡚⡥⢊⠶⣩⢎⡡⢚⠄⢃⠜⡢⣄⠣⡘⣬⢣⠿⣽⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⣯⢞⡵⣎⡷⣹⢎⣯⢳⡽⣳⡝⣮⢳⡽⣹⢧⡻⣜⢧⡻⣜⢧⣻⡜⣧⣛⢶⡹⣎⢷⡹⢶⣩⢏⠷⡮⣝⡞⣬⡓⣞⣱⢫⡜⣹⢬⣳⡾⠟⠋⠁⠀⢀⠀⠀⠀⢸⡅⣦⢉⡉⢿⣿⣿⣿⣿⣽⣿⣿⣿⣿⡿⣖⡻⢦⡛⣌⢏⡾⡵⢪⡕⢯⣌⢣⣌⡱⢎⡧⣙⣤⢏⡿⣵⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⢷⣫⢞⡵⣫⢗⡯⣞⢧⡻⣵⢻⡜⣧⢻⡵⣫⢷⡹⣎⢷⡹⣎⢷⡹⢶⡹⣎⢷⡹⢎⡗⣯⣜⢫⢷⡹⡖⣽⠲⣝⡼⢲⣍⣾⠟⠋⡁⢀⠀⠀⠀⢰⣿⠀⠀⠀⠈⡇⠸⣧⣌⣻⣟⣿⣿⣿⣿⣿⣿⣿⣿⡿⣥⣋⢷⡙⣞⣮⡽⣽⢳⣚⠷⣜⡲⣬⡳⢯⣶⢻⣼⣻⣞⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⣟⡼⣫⢞⡵⣫⢞⡽⣎⠷⣭⢳⡝⣮⢷⡹⢧⣏⢷⡹⣎⢷⡹⢮⡝⣧⢳⡝⡮⡝⣏⡞⢶⢎⡿⢬⡳⣝⠮⣝⣲⣽⠟⠋⠀⠠⠀⢀⡀⢀⡈⢷⣾⣿⠀⠀⢠⠀⢻⡄⢽⣷⣎⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢧⡍⣎⢿⣼⣳⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣾⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⡾⣱⣏⣞⡳⣝⢮⣳⢭⡟⣼⢫⡞⣵⢫⣝⡳⣎⢷⡹⣞⢧⣛⢧⢻⡜⣳⠞⡵⣋⢶⡹⣚⢮⡜⢧⣛⡼⣹⣶⠟⢡⣀⠈⢒⠠⣇⢢⣽⣦⣿⣿⣿⣿⠃⠀⠈⢣⠀⢳⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣟⡼⣣⢟⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⢿⣻⢯⣟⡳⡽⣎⢷⣛⣾⣳⣿⣿⣿⣿⣿⣿⣿
-- ⣳⢯⡽⣹⢧⡻⣜⢯⡞⣵⢫⡞⣵⢫⡞⣽⢣⡟⡼⢧⡻⣜⡻⣜⢮⣓⢏⡖⢧⠻⣜⡣⢟⣬⢓⡮⢫⣵⡿⠋⠀⠈⢻⣤⣚⡤⢿⡞⣿⣻⣿⣿⣿⠏⠀⠀⠀⠈⡆⠸⡄⠘⣿⣿⣿⣿⣿⣿⣿⣿⡵⣿⣿⣿⣧⣻⣾⣿⣿⣿⣿⣿⣿⣿⢿⡿⣿⣿⡿⣟⣿⣯⣿⣟⡿⣿⣻⣿⣽⣟⣷⣿⢾⣟⡾⣽⣳⢧⣻⣼⣻⣽⣿⣿⣿⣿⣿⣿⣿⣿
-- ⢯⡞⣵⢏⡾⣱⢯⡞⡽⣎⢷⡹⣎⢷⡹⣎⢷⡹⣝⢧⡟⣼⡱⢏⡶⢭⡺⣜⢫⣝⡲⢭⣓⢮⡹⣼⡟⠃⠀⠀⠀⣐⡠⠞⣿⡽⢎⡽⣶⢿⣾⢏⡆⠀⠀⠀⠀⠀⠑⠀⣧⠀⢺⣿⣿⣿⣿⣿⣿⡿⠀⣿⣿⣿⣿⣿⣿⣿⡿⣿⣻⣝⡮⣝⡾⣿⣳⣿⣟⣿⣿⣽⣷⣿⣿⣿⣿⣷⣿⣿⣿⣯⣿⣾⣟⣷⣿⣻⣷⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⣟⡼⣣⡟⣼⢣⡟⣼⢳⡝⣮⢳⡝⣮⢳⡝⣾⡱⣏⠾⣜⢧⡝⡞⣜⡣⢗⣎⠳⣎⣵⣫⣼⣶⠟⣉⣠⠀⠀⠀⢀⡿⣷⢍⣙⣧⣿⣾⣿⣫⣝⣾⣤⣄⣲⣤⣹⣦⠲⠤⣄⠀⠈⢿⣿⣿⣿⣿⣿⠃⢤⣿⣿⡿⢫⣙⢮⣳⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⣷⣿⡿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡷⢯
-- ⣞⡳⣝⢾⡱⣏⣞⢧⡻⣜⢧⡻⣜⢧⡟⣼⢣⡝⣮⣛⡼⢎⣞⡹⡲⣍⣷⡾⠟⢋⢉⣥⣶⣾⣿⣿⣿⣿⠿⡩⢞⣷⠟⠉⡐⢎⠛⡍⢯⡽⣻⣿⡻⢿⣿⣿⣿⣿⣷⣦⣜⣦⡀⠹⣿⣿⣿⣿⠏⢀⣿⡿⠉⢁⠣⣞⣯⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⡿⣟⣿⣟⣿⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⠾⣝⢯
-- ⣯⣝⢾⣣⢟⡼⣎⡷⣹⢎⣯⢳⡝⣮⡝⣮⢳⡝⢶⡹⣜⣫⣖⣽⠿⢋⡡⢴⠶⣞⡾⣞⣷⣿⣾⣿⣿⣟⡶⣡⣿⠋⠀⠀⢁⠢⠕⡚⢡⢎⡱⠭⣽⠿⣟⢿⡻⣝⣮⣿⣿⣿⣷⡧⣿⣿⣿⡋⢥⣿⡏⣠⣄⣠⣔⣫⢿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⢿⣿⣟⡿⣿⣾⣿⣿⡿⣟⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⣽⣯⢿⡽⣞
-- ⡷⢮⣳⡝⣮⢳⡝⣾⡱⣏⡞⣧⣛⢶⣽⣮⡷⠿⢛⠛⡫⢍⠋⡅⣎⢱⡙⣎⠿⣜⣻⡽⣿⣾⣿⣿⣿⣿⣿⣿⠏⢀⢠⡐⣠⠉⠒⠬⡁⢎⡰⢿⣬⡻⣜⣯⢷⣻⣿⣿⣿⣿⣿⣷⣉⡟⢦⡑⣮⢯⣴⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢷⣻⡾⣿⣟⣯⡿⣿⣿⣯⣟⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⡷⣯⡿⣽⢯
-- ⣽⢳⢧⡻⣜⢧⡻⢶⣹⢮⣽⡶⠿⠛⠉⠀⠐⠤⠣⡘⠐⢊⠒⡌⢂⠧⣜⡎⣷⣹⡾⣽⣷⡿⣿⣿⣿⣿⠿⣡⠲⣌⢶⡹⢿⣆⣙⣲⠱⣮⢙⠶⣣⢿⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡦⠥⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⢷⣯⣟⣷⣿⣳⣯⢿⡽⣷⣿⣾⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣳⣿⣿⡷⣟⣯⣿
-- ⣳⢯⡞⣵⣫⢞⣽⣳⠟⠋⠁⠀⠀⠀⠀⠐⠠⠂⢀⠈⠄⢡⠘⡰⣍⡞⣴⢯⡷⣯⣟⣿⡾⣟⡿⡹⣍⢆⡳⢣⡽⣘⣮⡟⣽⣿⣿⢣⠷⣌⣯⣛⣷⣻⢾⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⣶⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣟⣯⢷⡿⣜⢯⢾⣭⢿⡿⣿⡿⣿⣾⢿⣿⡿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣾⣿⣻⣿⣾
-- ⣟⢮⣽⢺⣵⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⣀⠢⡜⢢⡝⢲⣟⡾⣽⣯⣿⣿⣻⡽⣛⢥⢳⡱⢎⢎⣝⢣⡻⣵⣳⡿⣟⣿⣞⣯⢿⣝⡶⣛⡾⣽⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠉⢳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⣟⡾⣞⡯⣝⢿⣫⡗⣾⣯⣿⡽⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣟⣿⣷⣿
-- ⣻⢞⣼⡟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣂⠔⣠⠒⣭⠳⡜⣧⣿⣟⣷⣯⢷⣫⢇⡧⣙⢎⢣⠳⡞⡼⣌⢷⣻⢽⣯⢿⡽⣯⣟⡞⡿⣮⣽⢳⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠘⢦⡈⢿⣞⣿⣿⣿⣿⣷⡿⣿⣟⡾⣽⣟⡾⣽⢣⡟⣽⣺⢷⣻⢽⣳⣯⣿⢿⣻⣿⣻⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿
-- ⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⢬⡸⣔⢫⢖⣻⣾⣿⠿⣝⡾⣡⠧⣍⠞⣰⠙⢎⡲⢥⣛⣼⣻⡼⢯⡟⣞⢯⣿⣱⢿⡜⣷⡝⣾⢻⣶⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⢳⣄⡆⣹⣜⣿⣿⣿⣿⣿⣿⣿⢿⣟⣿⣳⢏⡷⣭⢗⣯⣛⣷⢻⣾⢯⣿⣻⣽⣿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢆⡞⠶⣱⣮⣾⣿⣿⢿⡽⣛⡮⢱⡡⣚⡜⡸⢣⢛⣤⡝⣫⣼⠶⡽⢾⡹⡞⡭⢞⠶⢭⢞⡹⣞⡽⣮⢿⣟⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡦⠀⣻⣽⢻⡼⣾⢿⣿⣿⢿⣻⣿⣿⣾⣳⢯⡻⣼⢛⡾⢧⣻⣼⣻⣾⢿⣽⣿⣻⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡒⡌⣞⣬⣿⣿⣿⣿⣿⣯⣿⡟⢧⠘⡅⣶⢩⠞⣱⢛⣼⢲⡝⣣⢟⡽⢞⡹⢻⡱⣛⢮⣙⣧⢫⡷⣭⢷⣯⣟⣾⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣰⣿⣿⣻⣿⣯⣿⣿⣿⣿⣿⣟⣮⢷⡏⣯⢳⣭⢻⡼⣟⣧⣿⣹⣽⣻⣯⣿⢿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⠀⠀⠀⠀⠀⠀⠄⠈⠀⠀⠀⡜⣰⣿⣿⣿⣻⣽⣯⢿⣿⣯⠳⡜⢠⢛⡘⢤⡃⣞⡥⢏⡞⡶⣙⢮⣟⡼⡳⣍⣳⣫⡝⣮⣝⣮⣻⡽⢯⣿⣾⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⡷⢧⣿⣿⣿⣿⢯⣟⡾⣽⢻⡯⣟⣳⡛⢾⣳⣽⡽⣞⡿⣿⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠠⡘⡼⣼⣿⣻⣷⢿⣽⣿⣽⣿⣿⣦⠃⡄⠙⠦⠸⠀⡗⡌⢲⡛⣜⠶⣙⡞⣼⣱⢯⣝⣣⢿⣝⣯⣟⣾⣳⣿⣿⢯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡿⣼⣿⣋⢿⡟⣞⣻⣞⡷⣹⢏⡷⣫⢷⣹⣛⣷⣻⣽⣿⣽⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
-- ⠀⠀⠀⠀⠀⠀⢠⡉⣥⢻⣽⣷⢿⣷⣯⣿⣿⣿⣿⣿⣿⠂⠄⠡⠒⠐⠈⠳⢐⡚⡡⢜⡭⢻⡴⣛⢶⣭⡞⣧⣟⣯⢿⣭⣟⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡛⢿⠙⣇⣿⢫⡝⣭⣓⣮⠷⣳⢾⣱⢟⣯⣟⣯⣷⣻⣾⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⣷⣟⡷⣯⣿⣿
-- ⠀⠀⣀⣄⣠⠌⢦⡱⣯⣿⣻⣾⡿⣯⣿⣿⣿⣿⣿⣿⡏⠙⠀⠀⠀⡰⣃⡤⢋⣜⣍⣫⣜⣣⣷⣻⣟⣶⡿⣟⣾⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⡉⠁⡫⢜⠣⢯⣜⣦⠳⣬⠷⣽⣚⣷⣞⣳⣾⣷⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⣿⣹⣿⣽⣯⣿
