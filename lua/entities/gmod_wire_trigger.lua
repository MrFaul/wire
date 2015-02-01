-- Wire Trigger created by mitterdoo
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName       = "Wire Trigger"
ENT.RenderGroup		= RENDERGROUP_BOTH
ENT.WireDebugName	= "Trigger"

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "TriggerSize" )
	self:NetworkVar( "Vector", 1, "TriggerOffset" )
	self:NetworkVar( "Entity", 0, "TriggerEntity" )
	self:NetworkVar( "Int", 0, "Filter" )
	self:NetworkVar( "Bool", 0, "OwnerOnly" )
end
function ENT:Draw()
	self:DrawModel()
end

if CLIENT then return end -- No more client

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject() if (phys:IsValid()) then phys:Wake() end

	self.Outputs = WireLib.CreateOutputs(self, { "EntCount", "Entities [ARRAY]" })

end

function ENT:Setup( model, filter, owneronly, sizex, sizey, sizez, offsetx, offsety, offsetz )

 	filter = math.Clamp( filter, 0, 2 )
 	sizex = math.Clamp( sizex, -1000, 1000 )
 	sizey = math.Clamp( sizey, -1000, 1000 )
 	sizez = math.Clamp( sizez, -1000, 1000 )
 	offsetx = math.Clamp( offsetx, -1000, 1000 )
 	offsety = math.Clamp( offsety, -1000, 1000 )
 	offsetz = math.Clamp( offsetz, -1000, 1000 )
	self.model = model
	self.filter = filter
	self.owneronly = owneronly
	self.sizex = sizex
	self.sizey = sizey
	self.sizez = sizez
	self.offsetx = offsetx
	self.offsety = offsety
	self.offsetz = offsetz

	self:SetOwnerOnly( tobool( owneronly ) )
	self:SetModel( model )
	self:SetFilter( filter )
	self:SetTriggerSize( Vector( sizex, sizey, sizez ) )
	self:SetTriggerOffset( Vector( offsetx, offsety, offsetz ) )

	local trig = ents.Create( "gmod_wire_trigger_entity" )
	trig:SetPos( self:LocalToWorld( self:GetTriggerOffset() ) )
	trig:SetAngles( self:GetAngles() )
	trig:PhysicsInit( SOLID_BBOX )
	trig:SetMoveType( MOVETYPE_VPHYSICS )
	trig:SetSolid( SOLID_BBOX )
	trig:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	trig:SetParent( self )
	trig:Spawn()

	local mins = self:GetTriggerSize() / -2
	local maxs = self:GetTriggerSize() / 2
	trig:SetCollisionBounds( mins, maxs )
	trig:SetCollisionGroup( 10 )
	trig:SetNoDraw( true )
	trig:SetTrigger( true )
	self:SetTriggerEntity( trig )
	trig:SetTriggerEntity( self )
	self:DeleteOnRemove( trig )

	self:ShowOutput()
end

function ENT:TriggerInput(iname, value)

end

function ENT:Think()
	self.BaseClass.Think(self)
	local trig = self:GetTriggerEntity()
	trig:SetTrigger(false)
	trig:SetPos( self:LocalToWorld( self:GetTriggerOffset() ) )
	trig:SetAngles( self:GetAngles() )
	trig:SetTrigger(true)
end

function ENT:ShowOutput()

	local txt = "Size: " .. tostring( self:GetTriggerSize() ) .. "\n"
	txt = txt .. "Offset: " .. tostring( self:GetTriggerOffset() ) .. "\n"
	txt = txt .. "Triggered by: " .. (
		self:GetFilter() == 0 and "#Tool.wire_trigger.filter_all" or
		self:GetFilter() == 1 and "#Tool.wire_trigger.filter_players" or
		self:GetFilter() == 2 and "#Tool.wire_trigger.filter_props"
	)

	self:SetOverlayText(txt)
end


duplicator.RegisterEntityClass("gmod_wire_trigger", WireLib.MakeWireEnt, "Data", "model", "filter", "owneronly", "sizex", "sizey", "sizez", "offsetx", "offsety", "offsetz" )