-- global variables. Must also be returned at the end of this file.
white = Color.Create(1,1,1,0.8)
dark = Color.Create(0,0,0,0.5)
transparent = Color.Create(0,0,0,0)
p = Font.Create("Trebuchet MS", 18)
h1 = Font.Create("Trebuchet MS", 25, {Bold=true})
h2 = Font.Create("Trebuchet MS", 25, {Italic=true, Bold=true})
h3 = Font.Create("Trebuchet MS", 25, {Bold=true})

-- example: Global.create_backgroundpane(800,600,{src=Image.File("/global/images/backgroundpane.png"), partsize=50, color=button_normal_color})
-- example: Global.create_backgroundpane(300,150) 
function create_backgroundpane(width, height, opt)
	imagesrc = opt.src or Image.File("/global/images/backgroundpane.png") --the image must be at least 3x partsize in height and width.
	paintcolor = opt.color or white
	imagesrc = Image.Multiply(imagesrc,paintcolor)
	srcimgw = Point.X(Image.Size(imagesrc))
	srcimgh = Point.Y(Image.Size(imagesrc))
	partsize = opt.partsize --or 50 --the partsize is one number. parts must be square.
	dblsize = Number.Multiply(partsize,2) -- just convenient because it's used a lot
	stretchfactorw = Number.Divide(Number.Subtract(width,dblsize),partsize) -- calculate how much we need to stretch the parts 
	stretchfactorh = Number.Divide(Number.Subtract(height,dblsize),partsize)
	--[[
	we're cutting the image up in 9 sections as follows
	tlc		tb		trc   
	lb		mid 	rb
	blc		bb		brc
 	]]
	-- toprow
	tlc = Image.Cut(imagesrc, Rect.Create(0,0,partsize,partsize)) -- top left corner
	tb = Image.Cut(imagesrc, Rect.Create(partsize, 0, dblsize, partsize)) -- top border
	-- we stretch the top border part
	tb = Image.Scale(tb, Point.Create(stretchfactorw,1))
	trc = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize),0,srcimgw,partsize)) -- top right corner
	-- mid row
	lb = Image.Cut(imagesrc, Rect.Create(0, partsize, partsize, dblsize)) -- left border
	mid = Image.Cut(imagesrc, Rect.Create(partsize, partsize, dblsize, dblsize)) -- middle 
	-- stretch the middle part
	mid = Image.Scale(mid, Point.Create(stretchfactorw,1))
	rb = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize), partsize, srcimgw, dblsize)) -- right border
	-- combine middle images in a single middle row.
	row = Image.Group({
		Image.Translate(lb, Point.Create(0,0)),
		Image.Translate(mid, Point.Create(partsize,0)),
		Image.Translate(rb, Point.Create(Number.Subtract(width,partsize),0)),
		})
	--stretch the completed middle row vertically
	row = Image.Scale(row, Point.Create(1, stretchfactorh)) 
	-- bottom row
	blc = Image.Cut(imagesrc, Rect.Create(0, Number.Subtract(srcimgh, partsize),partsize,srcimgh)) -- bottom left corner
	bb = Image.Cut(imagesrc, Rect.Create(partsize, Number.Subtract(srcimgh, partsize), dblsize, srcimgh)) 
	bb = Image.Scale(bb, Point.Create(stretchfactorw,1))
	brc = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize), Number.Subtract(srcimgh, partsize),srcimgw,srcimgh)) --bottom right corner
	-- position all parts relative to top left corner
	parts = {}
	parts[#parts+1] = tlc
	parts[#parts+1] = Image.Translate(tb, Point.Create(partsize,0))
	parts[#parts+1] = Image.Translate(trc, Point.Create(Number.Subtract(width,partsize),0))
	parts[#parts+1] = Image.Translate(row, Point.Create(0, partsize))
	parts[#parts+1] = Image.Translate(blc, Point.Create(0, Number.Subtract(height, partsize)))
	parts[#parts+1] = Image.Translate(bb, Point.Create(partsize, Number.Subtract(height, partsize)))
	parts[#parts+1] = Image.Translate(brc, Point.Create(Number.Subtract(width,partsize), Number.Subtract(height, partsize)))

	return Image.Group(parts)
end

function create_box(w, h, opt)
	--example create_box(300,700,{border_width=5, border_color=Color.Create(1,1,0), background_color=Color.Create(1,0,0)})
	-- or create_box(300,700)
	borderwidth = opt.border_width or 1
	bordercolor = opt.border_color or white
	backgroundcolor = opt.background_color or transparent
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
function rotateImage(image, degree)
	fraction = Number.Divide(degree,360)
	tau = 6.283185307179586476925286766559
	radialrotation = Number.Multiply(fraction,tau)
	return Image.Rotate(image,radialrotation)
end	

return {
	--global variables
	white = white,
	p = p,
	h1 = h1,
	h2 = h2,
	create_box = create_box,
	create_backgroundpane = create_backgroundpane,
	rotateImage = rotateImage,
}
