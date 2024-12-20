local BUTTON = {}

function BUTTON:Init()
	self.playHoverSound = true
end

function BUTTON:_Init()
	self.hoverStyle = {
		thicknessIncrease = {
			enable = false,
			thickness = 0,
			animationSpeed = self:GetTall() * 3.5,
			startHoverFunc = function( thickness, animationSpeed, height )
				return math.Clamp( thickness + animationSpeed * FrameTime(), 0, height * 0.5 )
			end,
			endHoverFunc = function( thickness, animationSpeed, height )
				return math.Clamp( thickness - animationSpeed * FrameTime(), 0, height * 0.5 )
			end
		},
		textColor = {
			enable = false,
			color = Color( 255, 255, 255 ),
			startHoverFunc = function( color, animationSpeed )
				color.r = math.Clamp( color.r - animationSpeed * FrameTime(), 100, 255 )
				color.g = math.Clamp( color.g - animationSpeed * FrameTime(), 100, 255 )
				color.b = math.Clamp( color.b - animationSpeed * FrameTime(), 100, 255 )
				return color
			end,
			endHoverFunc = function( color, animationSpeed )
				color.r = math.Clamp( color.r + animationSpeed * FrameTime(), 100, 255 )
				color.g = math.Clamp( color.g + animationSpeed * FrameTime(), 100, 255 )
				color.b = math.Clamp( color.b + animationSpeed * FrameTime(), 100, 255 )
				return color
			end
		}
	}
end

function BUTTON:Paint( w, h )
	if ( self:IsHovered() ) then
		if ( self.playHoverSound ) then
			self.playHoverSound = false
			sound.PlayFile( "sound/adminSystem/Abstract2.wav", "noplay", function( station )
				if IsValid( station ) then
					station:Play()
				end
			end )
		end
		local style = self.hoverStyle.thicknessIncrease
		if ( style.enable ) then
			style.thickness = style.startHoverFunc( style.thickness, h * 3.5, h )
		end
		style = self.hoverStyle.textColor
		if ( style.enable ) then
			style.startHoverFunc( style.color, 255 * 3.5 )
		end
	else
		self.playHoverSound = true
		local style = self.hoverStyle.thicknessIncrease
		if ( style.enable ) then
			style.thickness = style.endHoverFunc( style.thickness, h * 3.5, h )
		end
		style = self.hoverStyle.textColor
		if ( style.enable ) then
			style.endHoverFunc( style.color, 255 * 3.5 )
		end
	end
	self:WrappedPaint( w, h )
end

function BUTTON:DoClick()
	sound.PlayFile("sound/adminSystem/Minimalist12.wav", "noplay", function(station)
		if IsValid(station) then
			station:Play()
		end
	end)
	self:WrappedDoClick()
end

function BUTTON:WrappedPaint( w, h )
end

function BUTTON:WrappedDoClick()
end

vgui.Register( "admin_system_dbutton", BUTTON, "DButton" )
