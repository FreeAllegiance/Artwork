Colors = File.LoadLua("global/colors.lua")()

versionstring = "global alpha v0.04 "
-- FUNCTIONS
-- example: Global.create_backgroundpane(800,600,{src=Image.File("/global/images/backgroundpane.png"), partsize=50, color=button_normal_color})
-- example: Global.create_backgroundpane(300,150) 
function create_backgroundpane(width, height, opt)
	opt = opt or {}
	imagesrc = opt.src or Image.File("/global/images/backgroundpane_80pcOpacity.png") --the image must be at least 3x partsize in height and width.
	paintcolor = opt.color or Colors.white
	imagesrc = Image.Multiply(imagesrc,paintcolor)
	srcimgw = Point.X(Image.Size(imagesrc))
	srcimgh = Point.Y(Image.Size(imagesrc))
	partsize = opt.partsize or (Number.Min(srcimgw, srcimgh) / 3) --the partsize is one number. parts must be square.
	dblcornersize = Number.Multiply(partsize,2) -- just convenient because it's used a lot
	stretchfactorw = (width-dblcornersize)/(srcimgw-dblcornersize) -- calculate how much we need to stretch the parts 
	stretchfactorh = (height-dblcornersize)/(srcimgh-dblcornersize)
	--[[
	we're cutting the image up in 9 sections as follows
	tlc		tb		trc   
	lb		mid 	rb
	blc		bb		brc
 	]]
	-- toprow
	tlc = Image.Cut(imagesrc, Rect.Create(0,0,partsize,partsize)) -- top left corner
	tb = Image.Cut(imagesrc, Rect.Create(partsize, 0, srcimgw - partsize, partsize)) -- top border
	-- we stretch the top border part
	tb = Image.Scale(tb, Point.Create(stretchfactorw,1))
	trc = Image.Cut(imagesrc, Rect.Create(srcimgw - partsize,0,srcimgw,partsize)) -- top right corner
	-- mid row
	lb = Image.Cut(imagesrc, Rect.Create(0, partsize, partsize, srcimgh - partsize)) -- left border
	mid = Image.Cut(imagesrc, Rect.Create(partsize, partsize, srcimgw - partsize, srcimgh - partsize)) -- middle 
	rb = Image.Cut(imagesrc, Rect.Create(srcimgw - partsize, partsize, srcimgw, srcimgh - partsize)) -- right border
	-- stretch the middle part
	lb = Image.Scale(lb, Point.Create(1,stretchfactorh))
	mid = Image.Scale(mid, Point.Create(stretchfactorw,stretchfactorh))
	rb = Image.Scale(rb, Point.Create(1,stretchfactorh))
	-- combine middle images in a single middle row.
	row = Image.Group({
		Image.Translate(lb, Point.Create(0,0)),
		Image.Translate(mid, Point.Create(partsize,0)),
		Image.Translate(rb, Point.Create(width-partsize,0)),
		})
	-- bottom row
	blc = Image.Cut(imagesrc, Rect.Create(0, srcimgh - partsize,partsize,srcimgh)) -- bottom left corner
	bb = Image.Cut(imagesrc, Rect.Create(partsize, srcimgh - partsize, srcimgw - partsize, srcimgh)) 
	bb = Image.Scale(bb, Point.Create(stretchfactorw,1))
	brc = Image.Cut(imagesrc, Rect.Create(srcimgw - partsize, srcimgh - partsize,srcimgw,srcimgh)) --bottom right corner
	-- position all parts relative to top left corner
	parts = {}
	parts[#parts+1] = tlc
	parts[#parts+1] = Image.Translate(tb, Point.Create(partsize,0))
	parts[#parts+1] = Image.Translate(trc, Point.Create(width-partsize,0))
	parts[#parts+1] = Image.Translate(row, Point.Create(0, partsize))
	parts[#parts+1] = Image.Translate(blc, Point.Create(0, height-partsize))
	parts[#parts+1] = Image.Translate(bb, Point.Create(partsize, height-partsize))
	parts[#parts+1] = Image.Translate(brc, Point.Create(width-partsize,height-partsize))

	return Image.Group(parts)
end

function create_box(w, h, opt)
	--example Global.create_box(300,700,{border_width=5, border_color=Color.Create(1,1,0), background_color=Color.Create(1,0,0)})
	-- or create_box(300,700)
	opt = opt or {}
	borderwidth = opt.border_width or 1
	bordercolor = opt.border_color or Colors.white
	backgroundcolor = opt.background_color or Colors.transparent
	yoffset = Number.Multiply(borderwidth, 2)
	boxarea = Image.Extent(Point.Create(w, h), backgroundcolor)
	borderhoriz = Image.Extent(Point.Create(w, borderwidth), bordercolor)
	bordervert = Image.Extent(Point.Create(borderwidth,Number.Subtract(h, yoffset)), bordercolor)
	box = Image.Group({		
		boxarea,
		borderhoriz,
		Image.Translate(bordervert,Point.Create(0,borderwidth)),
		Image.Translate(bordervert,Point.Create(Number.Subtract(w,borderwidth), borderwidth)),
		Image.Translate(borderhoriz, Point.Create(0, Number.Subtract(h, borderwidth))),

		})
	return box
end

-- this function allows you to use degrees rather than radials to rotate images.
function rotate_image_degree(image, degree)
	fraction = Number.Divide(degree,360)
	tau = 6.283185307179586476925286766559
	radialrotation = Number.Multiply(fraction,tau)
	return Image.Rotate(image,radialrotation)
end	

function list_sum(lst)
	sum = 0
	lst = lst
	for i,val in ipairs(lst) do
		sum = Number.Add(sum,val)
	end	
	return sum
end

function list_concat(lst, separator)
--	n = 0
--	for i in pairs(lst) do n=n+1 end
	sp = separator or ""
	ln = ""
	if space == true then sp = " " end
	for i,val in ipairs(lst) do
		if i>1 then ln=String.Concat(ln,sp) end
		ln = String.Concat(ln,val)
	end	
	return ln
end

----------- scrollbar code -----------------


-- this function is dimension-agnostic:
-- feed it an image and it will figure out wether the scrollbar is supposed to be horizontal or vertical
-- scale_scrollbarpart([image file], [integer, desired length or width], [integer, ends of the bar that should not be scaled])
-- example: scale_scrollbarpart(Image.File("path/image.png"), 800, 10)

function scale_scrollbarpart(image, i_dimension, i_partsize)
	origwidth = Point.X(Image.Size(image))
	origheight = Point.Y(Image.Size(image))
	scalefactor = (i_dimension-(2*i_partsize))/i_partsize-0.001 -- calculate how much we need to stretch the middle part, the 2's are for 1px overlaps on both ends

	function horizontal_scrollbar()
			leftpart = Image.Cut(image, Rect.Create(0,0,i_partsize,origheight))
			midpart = Image.Scale(Image.Cut(image, Rect.Create(i_partsize,0, i_partsize*2, origheight)),Point.Create(scalefactor,1))
			rightpart = Image.Cut(image, Rect.Create(origwidth-i_partsize,0,origwidth,origheight))
		return Image.Group({
				leftpart,
				Image.Translate(midpart,Point.Create(i_partsize,0)),
				Image.Translate(rightpart, Point.Create(i_dimension-i_partsize,0))
			})
	end
	function vertical_scrollbar()
		toppart = Image.Cut(image, Rect.Create(0,0, origwidth, i_partsize))
		midpart = Image.Scale(Image.Cut(image, Rect.Create(0, i_partsize, origwidth, i_partsize*2)),Point.Create(1, scalefactor))
		bottompart = Image.Cut(image, Rect.Create(0, origheight-i_partsize,origwidth, origheight))
		return Image.Group({
			toppart,
			Image.Translate(midpart,Point.Create(0, i_partsize)),
			Image.Translate(bottompart, Point.Create(0, Point.Y(Image.Size(midpart))+i_partsize))
			})
	end

	scrollbarpart = Image.Switch(
		Number.Min(Number.Max(0,origwidth-origheight),1),
		{
		[0]=vertical_scrollbar(),
		[1]=horizontal_scrollbar()
		})

	return scrollbarpart
end


function create_vertical_scrollbar(position_fraction, height, grip_height, paint)
	--[[
	Im considering doing this completely differently, without artwork.
	basically make a the parts by using Image.Extents to make vertical / horizontal lines.
	a 4px wide line with a slightly longer, 2px wide line on top, sticking out 1px on both ends.
	maybe apply an 'antialiasing effect' by adding a semi-transparent line to finish up.
	saves a lot of scaling, cutting and painting.
	]]
	grip_original = Image.Multiply(Image.File("global/images/scrollbargrip_roundedline.png"), paint)
	staticEndSize = 14 -- in px
	grip = scale_scrollbarpart(grip_original, grip_height, staticEndSize)
	--scrollbarbg_original = Image.Multiply(Image.File("global/images/scrollbar_bg_thin.png"), paint)
	scrollbarbg_original = Image.Multiply(Image.File("global/images/scrollbargrip_roundedline.png"), Color.Create(1,1,1,0.25))
	scrollbarbg = scale_scrollbarpart(scrollbarbg_original, height, staticEndSize)
	scrollbar_width = Point.X(Image.Size(scrollbarbg))
	
 	scrollbar_translation_per_fraction = Number.Subtract(height, grip_height)
	fraction_per_scrollbar_translation = Number.Divide(1, scrollbar_translation_per_fraction)
	
	grip_translation = Point.Create(0, Number.Add(0, Number.Multiply(position_fraction, scrollbar_translation_per_fraction)))

	grip_translated = Image.MouseEvent(Image.Translate(grip, grip_translation))

	Event.OnEvent(position_fraction, Event.GetPoint(grip_translated, "drag"), function (dragged)
		return Number.Clamp(Number.Add(position_fraction, Number.Multiply(fraction_per_scrollbar_translation, Point.Y(dragged))), 0, 1)
	end)

	return {
		width=scrollbar_width,
		image=Image.Group({
			scrollbarbg,
			grip_translated,
		})
	}
end

function create_vertical_scrolling_container(target_image, container_size, paint)
	-- retrieve the dimensions of the scrolling window
	container_width = Point.X(container_size)
	container_height = Point.Y(container_size)
	-- retrieve dimensions of the image to be placed inside
	target_size = Image.Size(target_image)
	target_height = Point.Y(target_size)

	paint = paint or Color.Create(0.6, 0.6, 0.6)

	function make_scroll_window()
		position_fraction = Number.CreateEventSink(0)
		grip_height = Number.Max(50, Number.Min(Number.Round((container_height/target_height)*container_height,0),container_height))
		scrollbar = create_vertical_scrollbar(position_fraction, container_height, grip_height, paint)
		cut_width = Number.Subtract(container_width, scrollbar.width)
		offset_x = 0
		offset_y = Number.Round(Number.Multiply(position_fraction, Number.Subtract(target_height, container_height)),0)
		scroll_window = Image.Group({
			Image.Cut(target_image, Rect.Create(offset_x, offset_y, cut_width, Number.Add(offset_y, container_height))),
			Image.Translate(scrollbar.image, Point.Create(cut_width, 0))
		})
		return scroll_window
	end 
	
	return Image.Switch(
		Number.Min(1, Number.Max(0,target_height-container_height)),
		{
		[0]= target_image,
		[1]= make_scroll_window(),
		}
	)
end

return {
	-- other
	version = versionstring,
	-- global functions
	list_sum = list_sum,
	list_concat = list_concat,
	create_box = create_box,
	create_backgroundpane = create_backgroundpane,
	create_vertical_scrolling_container=create_vertical_scrolling_container,
	rotate_image_degree = rotate_image_degree,
}
