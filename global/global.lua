
-- create_background_pane(width as multiples of x pixels, height as multiple of x pixels, optional args: image to use, number partsize) 
function create_backgroundpane(width, height, imagesrc, partsize, color)
	imagesrc = imagesrc or Image.File("/global/images/backgroundpane.png") --the image must be at least 3x partsize in height and width.
	paintcolor = color or Color.Create(1, 1, 1, 0.7)
	imagesrc = Image.Multiply(imagesrc,paintcolor)
	srcimgw = Point.X(Image.Size(imagesrc))
	srcimgh = Point.Y(Image.Size(imagesrc))
	partsize = partsize or 50 --the partsize is one number. parts must be square.
	dblsize = Number.Multiply(partsize,2) -- just convenient because it's used a loy
	stretchfactorw = Number.Divide(Number.Subtract(width,dblsize),partsize)
	stretchfactorh = Number.Divide(Number.Subtract(height,dblsize),partsize)

	parts = {}
	-- toprow
	tlc = Image.Cut(imagesrc, Rect.Create(0,0,partsize,partsize))
	tb = Image.Cut(imagesrc, Rect.Create(partsize, 0, dblsize, partsize))
	tb = Image.Scale(tb, Point.Create(stretchfactorw,1))
	trc = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize),0,srcimgw,partsize))
	-- mid rows
	lb = Image.Cut(imagesrc, Rect.Create(0, partsize, partsize, dblsize))
	mid = Image.Cut(imagesrc, Rect.Create(partsize, partsize, dblsize, dblsize))
	mid = Image.Scale(mid, Point.Create(stretchfactorw,1))
	rb = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize), partsize, srcimgw, dblsize))
	-- combine middle images in a single middle row.
	row = Image.Group({
		Image.Translate(lb, Point.Create(0,0)),
		Image.Translate(mid, Point.Create(partsize,0)),
		Image.Translate(rb, Point.Create(Number.Subtract(width,partsize),0)),
		})
	row = Image.Scale(row, Point.Create(1, stretchfactorh)) --stretch the completed middle row vertically
	-- bottom row
	blc = Image.Cut(imagesrc, Rect.Create(0, Number.Subtract(srcimgh, partsize),partsize,srcimgh))
	brc = Image.Cut(imagesrc, Rect.Create(Number.Subtract(srcimgw, partsize), Number.Subtract(srcimgh, partsize),srcimgw,srcimgh))
	bb = Image.Cut(imagesrc, Rect.Create(partsize, Number.Subtract(srcimgh, partsize), dblsize, srcimgh)) 
	bb = Image.Scale(bb, Point.Create(stretchfactorw,1))

-- Image.Scale(part, Point.Create(Number.Divide(required_width, part_width), 1)

	parts[#parts+1] = Image.Translate(tlc, Point.Create(0,0))
	parts[#parts+1] = Image.Translate(tb, Point.Create(partsize,0))
	parts[#parts+1] = Image.Translate(trc, Point.Create(Number.Subtract(width,partsize),0))
	parts[#parts+1] = Image.Translate(row, Point.Create(0, partsize))
	parts[#parts+1] = Image.Translate(blc, Point.Create(0, Number.Subtract(height, partsize)))
	parts[#parts+1] = Image.Translate(bb, Point.Create(partsize, Number.Subtract(height, partsize)))
	parts[#parts+1] = Image.Translate(brc, Point.Create(Number.Subtract(width,partsize), Number.Subtract(height, partsize)))

	-- now combine all parts into new group image 
	export_image = 
	Image.Group({
			-- Image.Extent(Rect.Create(0,0,width, height), Color.Create(1,0,0,0.5)),
			--Image.Group({tlc, tb, trc, lb, rb, blc, bb, brc}),
			Image.Group(parts),
			--Image.Justify(Image.Group(parts), Point.Create(width,height), Justify.Center),
			-- Image.Translate(border, Point.Create(200,200)),
			--Image.Group({corner,middle, border}),
		})

	return export_image 
end

function rotateImage(image, degree)
	fraction = Number.Divide(degree,360)
	tau = 6.283185307179586476925286766559
	radialrotation = Number.Multiply(fraction,tau)
	return Image.Rotate(image,radialrotation)
end	

return {
	create_backgroundpane = create_backgroundpane,
	rotateImage = rotateImage,
}
