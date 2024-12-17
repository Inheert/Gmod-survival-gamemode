local DSCROLLPANEL = {}

function DSCROLLPANEL:Init()
	self:CustomizeVBar()
end

function DSCROLLPANEL:_Init()
end

function DSCROLLPANEL:Paint( w, h )
	self:WrappedPaint( w, h )
end

function DSCROLLPANEL:WrappedPaint( w, h )
end

function DSCROLLPANEL:CustomizeVBar()
	local DSCROLLBAR = self:GetVBar()
	
	function DSCROLLBAR:Paint( w, h )
		surface.SetDrawColor( 70, 70, 70 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	function DSCROLLBAR.btnGrip:Paint( w, h )
		surface.SetDrawColor( 90, 90, 90 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	function DSCROLLBAR.btnUp:Paint( w, h )
		surface.SetDrawColor( 50, 50, 50 )
		surface.DrawRect( 0, 0, w, h )
	
		draw.SimpleText( "▲", "CustomButtonFont14", w * 0.5, h * 0.5, Color( 150, 150, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	function DSCROLLBAR.btnDown:Paint( w, h )
		surface.SetDrawColor( 50, 50, 50 )
		surface.DrawRect( 0, 0, w, h )
	
		draw.SimpleText( "▼", "CustomButtonFont14", w * 0.5, h * 0.5, Color( 150, 150, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end


vgui.Register( "admin_system_dscrollpanel", DSCROLLPANEL, "DScrollPanel" )
