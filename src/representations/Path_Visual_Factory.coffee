###

Written on Oct.07.2017 by Bryce Summers
Purpose: Creates THREE.js paths.

###

class EX.Path_Visual_Factory

    constructor: (polyline, width, color, show_outline) ->
        @vecs  = @_BDS_Polyline_to_THREE_vertex_list(polyline)
        @width = width
        @color = color

        @spline = new THREE.CatmullRomCurve3(@vecs)
        @curve = new BDS.Curve(@spline)

        @show_outline = show_outline

    # BDS. Polyline, float, THREE.Color
    getPathVisual: () ->

        return @getVisual(1, @curve, @width, @color)


    # Max length is the maximum length per segment.
    # the curve is the spline that defines the center of the path.
    getVisual: (max_length, curve, width, color) ->

        offset_amount = width/2
        curve.updateDiscretization(max_length)

        # -- Compute various lines for the path.
        # We will pack them into a single THREE.js Object.


        # For now, we will use simple black strokes.
        material = EX.style.m_default_line.clone()
        material.color = EX.style.c_default_line

        middle_material = EX.style.m_default_line.clone()
        middle_material.color = EX.style.c_default_line

        ###
        middle_line = new THREE.Geometry()
        middle_line.vertices = curve.getDiscretization()
        ###
        
        times_left  = []
        times_right = []
        verts_left  = []
        verts_right = []

        left_line  = new THREE.Geometry()
        verts_left = curve.getOffsets(max_length, offset_amount, times_left)
        left_line.vertices = verts_left

        right_line  = new THREE.Geometry()
        verts_right = curve.getOffsets(max_length, -offset_amount, times_right)
        right_line.vertices = verts_right

        # Compute fill, using time lists to determine indices for the faces.
        fill_geometry = @_get_fill_geometry(verts_left, verts_right, times_left, times_right)
        fill_material = EX.style.m_flat_fill.clone()
        fill_material.color = color

        @fill_material = fill_material

        output = new THREE.Object3D()
        fill   = new THREE.Object3D()
        output.add(fill)

        fill_mesh = new THREE.Mesh( fill_geometry, fill_material )
        fill_mesh.position.z = -.01 # Draw fill behind.
        output.add(fill_mesh)

        if @show_outline
            #output.add(new THREE.Line( middle_line, middle_material ))
            output.add(new THREE.Line( left_line,   material ))
            output.add(new THREE.Line( right_line,  material ))

        return output

    # Creates a fill polygon based on the input times.
    # Due to line curvature, vertices at higher curvature regions will exhibit higher degrees in this polygonalization.
    # Assumes each list of times ends on the same time, the times increase strictly monototically.
    _get_fill_geometry: (left_verts, right_verts, times_left, times_right) ->

        output = new THREE.Geometry()
        output.vertices = left_verts.concat(right_verts)
        faces = output.faces

        l_len = left_verts.length
        r_len = right_verts.length

        l_index = 0
        r_index = 0

        l_time = 0.0
        r_time = 0.0

        while l_index < l_len - 1 or r_index < r_len - 1

            left_time  = times_left[l_index]
            right_time = times_right[r_index]

            big_left  = false
            big_left  = left_time  < right_time

            # Break tie using by comparing the next couple of points.
            if left_time == right_time
                big_left  = times_left[l_index + 1] < times_right[r_index + 1]

            # Use 2 left vertices and 1 right vertex.
            if big_left
                face = new THREE.Face3(l_index, l_index + 1, r_index + l_len)
                # We use a model to allow collision queries to pipe back to this road object with time domain knowledge.
                faces.push(face)
                l_index += 1
                continue

            # Big right otherwise.
            face = new THREE.Face3(r_index + 1 + l_len, r_index + l_len, l_index)
            faces.push(face)
            r_index += 1
            continue

        # THREE.Geometry
        return output


    # THREE.Vector3[] -> BDS.Polyline
    _BDS_Polyline_to_THREE_vertex_list: (polyline) ->
        pts = polyline.toPoints()

        vecs = []

        for pt in pts
            vec = new THREE.Vector3(pt.x, pt.y, pt.z)
            vecs.push(vec)

        if polyline.isClosed()
            pt = pts[0]
            vecs.push(new THREE.Vector3(pt.x, pt.y, pt.z))
            pt = pts[1]
            vecs.push(new THREE.Vector3(pt.x, pt.y, pt.z))

        return vecs

    # THREE.Vector3[] -> BDS.Polyline
    _THREE_vertex_list_to_BDS_Polyline: (vectors) ->
        out = new BDS.Polyline()

        for vec in vectors
            out.addPoint(new BDS.Point(vec.x, vec.y))

        return out