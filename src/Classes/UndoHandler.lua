-- Path of Building
--
-- Class: Undo Handler
-- Handler for classes that need to provide undo/redo functionality
-- Classes that use this must define 2 functions:
-- undoState = :CreateUndoState()	Returns a new undo state that reflects the current state
-- :RestoreUndoState(undoState)		Reverts the current state to the given undo state
--
local t_insert = table.insert
local t_remove = table.remove

local UndoHandlerClass = newClass("UndoHandler", function(self)
	self.undoStates = { }
	self.currentUndoState = 0
end)

-- Initialises the undo/redo buffers
-- Should be called after the current state is first loaded/initialised
function UndoHandlerClass:ResetUndo()
	self.undoStates = wipeTable(self.undoStates)
	self.undoStates[1] = self:CreateUndoState()
	self.currentUndoState = 1
end

-- Adds a new undo state to the undo buffer, and also clears the redo buffer
-- Should be called after the user makes a change to the current state
function UndoHandlerClass:AddUndoState()
	for i = #self.undoStates,self.currentUndoState + 1,-1 do
		t_remove(self.undoStates)
	end
	local newState = rebase(self:CreateUndoState(), self.undoStates[#self.undoStates])
	t_insert(self.undoStates, newState)
	if #self.undoStates >= 100 then
		t_remove(self.undoStates, 1)
	end
	self.currentUndoState = #self.undoStates
	self.modFlag = true
end

-- Reverts the current state to the previous undo state
function UndoHandlerClass:Undo()
	if self.currentUndoState > 1 then
		self.currentUndoState = self.currentUndoState - 1
		self:RestoreUndoState(copySafe(self.undoStates[self.currentUndoState], false, true))
	end
end

-- Reverts the most recent undo operation
function UndoHandlerClass:Redo()
	if self.currentUndoState < #self.undoStates then
		self.currentUndoState = self.currentUndoState + 1
		self:RestoreUndoState(copySafe(self.undoStates[self.currentUndoState], false, true))
	end
end
