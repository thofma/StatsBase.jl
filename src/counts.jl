# Counts of discrete values

#################################################
#
#  counts on integer ranges
#
#  These methods are the most efficient if one
#  knows that all values fall in a small range
#  of integers.
#  
#################################################

#### functions for counting a single list of integers (1D)

function addcounts!(r::AbstractArray, x::IntegerArray, rgn::Range1)
	# add counts of integers from x to r

	k = length(rgn)
	length(r) == k || raise_dimerror()

	m0 = rgn[1]
	m1 = rgn[end]
	b = m0 - 1
	
	@inbounds for i in 1 : length(x)
		xi = x[i]
		if m0 <= xi <= m1
			r[xi - b] += 1  
		end
	end
	return r
end

function addcounts!(r::AbstractArray, x::IntegerArray, wv::WeightVec, rgn::Range1)
	k = length(rgn)
	length(r) == k || raise_dimerror()

	m0 = rgn[1]
	m1 = rgn[end]
	b = m0 - 1
	w = values(wv)
	
	@inbounds for i in 1 : length(x)
		xi = x[i]
		if m0 <= xi <= m1
			r[xi - b] += w[i]  
		end
	end
	return r
end

counts(x::IntegerArray, rgn::Range1) = addcounts!(zeros(Int, length(rgn)), x, rgn)
counts(x::IntegerArray, wv::WeightVec, rgn::Range1) = addcounts!(zeros(eltype(wv), length(rgn)), x, wv, rgn)

proportions(x::IntegerArray, rgn::Range1) = counts(x, rgn) .* inv(length(x))
proportions(x::IntegerArray, wv::WeightVec, rgn::Range1) = counts(x, wv, rgn) .* inv(sum(wv))


#### functions for counting a single list of integers (2D)

function addcounts!(r::AbstractArray, x::IntegerArray, y::IntegerArray, xrgn::Range1, yrgn::Range1)
	# add counts of integers from x to r

	kx = length(xrgn)
	ky = length(yrgn)
	size(r) == (kx, ky) || raise_dimerror()

	mx0 = xrgn[1]
	mx1 = xrgn[end]
	my0 = yrgn[1]
	my1 = yrgn[end]

	bx = mx0 - 1
	by = my0 - 1
	
	for i in 1 : length(x)
		xi = x[i]
		yi = y[i]
		if (mx0 <= xi <= mx1) && (my0 <= yi <= my1)
			r[xi - bx, yi - by] += 1  
		end
	end
	return r
end

function addcounts!(r::AbstractArray, x::IntegerArray, y::IntegerArray, wv::WeightVec, xrgn::Range1, yrgn::Range1)
	# add counts of integers from x to r

	kx = length(xrgn)
	ky = length(yrgn)
	size(r) == (kx, ky) || raise_dimerror()

	mx0 = xrgn[1]
	mx1 = xrgn[end]
	my0 = yrgn[1]
	my1 = yrgn[end]

	bx = mx0 - 1
	by = my0 - 1
	w = values(wv)
	
	for i in 1 : length(x)
		xi = x[i]
		yi = y[i]
		if (mx0 <= xi <= mx1) && (my0 <= yi <= my1)
			r[xi - bx, yi - by] += w[i] 
		end
	end
	return r
end

function counts(x::IntegerArray, y::IntegerArray, xrgn::Range1, yrgn::Range1)
	addcounts!(zeros(Int, length(xrgn), length(yrgn)), x, y, xrgn, yrgn)
end

function counts(x::IntegerArray, y::IntegerArray, wv::WeightVec, xrgn::Range1, yrgn::Range1)
	addcounts!(zeros(eltype(wv), length(xrgn), length(yrgn)), x, y, wv, xrgn, yrgn)
end

proportions(x::IntegerArray, y::IntegerArray, xrgn::Range1, yrgn::Range1) = counts(x, y, xrgn, yrgn) .* inv(length(x))
proportions(x::IntegerArray, y::IntegerArray, wv::WeightVec, xrgn::Range1, yrgn::Range1) = counts(x, y, wv, xrgn, yrgn) .* inv(sum(wv))



#################################################
#
#  counts on distinct values
#
#  These methods are based on dictionaries, and 
#  can be used on any kind of hashable values.
#  
#################################################

function addcounts!{T}(cm::Dict{T}, x::AbstractArray{T})
	for v in x
		cm[v] = get(cm, v, 0) + 1
	end
	return cm
end

function addcounts!{T,W}(cm::Dict{T}, x::AbstractArray{T}, wv::WeightVec{W})
	n = length(x)
	length(wv) == n || raise_dimerror()
	w = values(wv)
	z = zero(W)

	@inbounds for i = 1 : n
		xi = x[i]
		wi = w[i]
		cm[xi] = get(cm, xi, z) + wi
	end
	return cm
end

countmap{T}(x::AbstractArray{T}) = addcounts!((T=>Int)[], x)
countmap{T,W}(x::AbstractArray{T}, wv::WeightVec{W}) = addcounts!((T=>W)[], x, wv)

function _normalize_countmap{T}(cm::Dict{T}, s::Real)
	r = (T=>Float64)[]
	for (k, c) in cm
		r[k] = c / s 
	end
	return r
end

proportionmap(x::AbstractArray) = _normalize_countmap(countmap(x), length(x))
proportionmap(x::AbstractArray, wv::WeightVec) = _normalize_countmap(countmap(x, wv), sum(wv))


