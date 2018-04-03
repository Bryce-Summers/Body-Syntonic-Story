###
# Written by Bryce Summers on 10.23.2017
# 
# Allows THREE.js visuals to be built from polylines, polygons, strings, etc.
###

class EX.Visual_Factory

    constructor: () ->

        EX.Visual_Factory.unit_meshes = new EX.Unit_Meshes()
    ###
        # Local Variables.

        # Root of THREE.JS visualization.
        @scene = new THREE.Scene()
        
        # Simple Meshes, such as circles creator.
        @unit_meshes = new BDS.Unit_Meshes(EX.style.m_flat_fill, EX.style.m_flat_fill, EX.style.m_default_line)

        #@init_test_scene()
        @input_root = null

        @init_test_bryce_image()

    init_test_scene: () ->

        # Test Line on the screen.
        pts = [new BDS.Point(0, 0), new BDS.Point(100, 100), new BDS.Point(500, 100)]
        polyline = new BDS.Polyline(false, pts)
        @newCurve(polyline, new THREE.Color(0, 0, 0))

        # Test a path on screen.
        pts = [new BDS.Point(0, 200), new BDS.Point(100, 300), new BDS.Point(500, 300)]
        polyline = new BDS.Polyline(false, pts)
        @newPath(polyline, 50, new THREE.Color(1, 0, 0))

        # Test a path on screen.
        pts = [new BDS.Point(500, 500), new BDS.Point(600, 500), new BDS.Point(550, 700)]
        polyline = new BDS.Polyline(false, pts)
        @newPolygon(polyline, 50, new THREE.Color(0, 0, 1))
        @newPoint(new BDS.Point(800, 350), new THREE.Color(0, 0, 1))
    ###

    # Unit Geometries for rendering.
    # This needs to be below the style specifications, because it looks them up in its constructor.
    @unit_meshes = null
    @textMeshQueue = []
    @textureLoader = new THREE.TextureLoader()

    # BDS.Polyline, THREE.Color -> Single thickness curve.
    @newCurve: (polyline, color) ->

        if polyline.size() < 2
            return


        geom = new THREE.Geometry();
        
        pts = polyline.toPoints()
        if polyline.isClosed()
            pts.push(pts[0])

        for pt in pts
            geom.vertices.push(new THREE.Vector3(pt.x, pt.y, pt.z))


        line_material = EX.style.m_default_line.clone()
        line_material.color = color.clone()

        mesh = new THREE.Line(geom, line_material)
        return mesh

    # BDS.Polyline, THREE.Color -> 
    @newPath: (polyline, width, color, show_outline) ->

        if not show_outline
            show_outline = false

        if polyline.size() < 2 or (polyline.isClosed() and polyline.size < 3)
            return null

        pathFactory = new EX.Path_Visual_Factory(polyline, width, color, show_outline)
        mesh = pathFactory.getPathVisual()
        return mesh


    # BDS.Polyline, THREE.Color ->
    @newPolygon: (polygon, color) ->

        pts = polygon.toPoints()
        vecs = []
        for pt in pts
            vecs.push(new THREE.Vector3(pt.x, pt.y, pt.z))

        shape = new THREE.Shape(vecs)

        geometry = new THREE.ShapeGeometry( shape )
        material = EX.style.m_flat_fill.clone()
        mesh = new THREE.Mesh( geometry, material )
        return mesh


    @newPoint: (pt, color, radius) ->
        scale = new THREE.Vector3(radius, radius, 1)

        pos = new THREE.Vector3(pt.x, pt.y, 0)

        material = EX.style.m_flat_fill.clone()

        mesh  = @unit_meshes.newCircle({color:color
                             ,material:material
                             ,position:pos
                             ,scale:scale})
        return mesh


    ###

    External API.

    ###

    # Provides a link to the root of the input controller tree.
    @setInputRoot: (input) ->
        input_root = input


    @getVisual: () ->
            return @scene

    # str is the message spelled in the label.
    # FIXME: HAVE input configuration not be hardcoded.
    @new_label: (str) ->

        # params: {font: (FontLoader), message: String, height:, out:,
        #           fill_color:0xrrggbb, outline_color:0xff}
        obj = new THREE.Object3D()
        params = {font: EX.style.fontLoader, message: str, height:20, out: obj, fill_color:0x000000, outline_color:0x111111}
        EX.Visual_Factory.newText(params)

        obj.position.copy(new THREE.Vector3(-50, 20, -100))
        obj.scale.copy(new THREE.Vector3(1, -1, 1))
        obj.rotation.copy(new THREE.Vector3(0, 0, Math.PI/2))

        return obj

    # Returns a material that will contain the given texture when loaded.
    ###
    EX.style.load_texture = (url) ->
        material = new THREE.MeshBasicMaterial( {
            map: null
         } );

        loader = new THREE.TextureLoader();

        # load the resource
        loader.load(
            url,
            (texture) ->
                # Color map the material to the loaded texture.
                material.map = texture

                texture.wrapS = THREE.RepeatWrapping;
                texture.wrapT = THREE.RepeatWrapping;
                texture.repeat.set( 40, 40);
            ,
            (xhr) ->
                console.log( (xhr.loaded / xhr.total * 100) + '% loaded' )
            ,
            # Function called when download errors
            ( xhr ) ->
                console.log( "The texture at url: " + url + "  was not loaded." )
        )

        return material
    ###

    # dim {x:, y: w:, h:}
    @newSprite = (url, dim) ->
        
        texture = EX.Visual_Factory.textureLoader.load(url)
        geom = new THREE.PlaneBufferGeometry( dim.w, dim.h, 32 )
        mat  = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide, map:texture, transparent: true} )
        mesh = new THREE.Mesh( geom, mat )

        mesh.position.x = dim.w/2
        mesh.position.y = dim.h/2

        mesh.rotation.z = Math.PI

        mesh.scale.x = -1

        # We use a container, so the sprite is now aligned with a position at its top left corner on the screen.
        container = new THREE.Object3D()
        container.add(mesh)

        container.position.x = dim.x
        container.position.y = dim.y

        return container


    # params: {font: (FontLoader), message: String, height:, out:,
    #           fill_color:0xrrggbb, outline_color:0xff}
    # FIXME: Text is assumed to be left aligned, but I may allow for center alignment eventually.
    # It is expected that the user will position the containing object externally,
    # so that the internal text shapes may be replaced.
    # Creates a new object that contins an outline form and a fill form.
    # adds the object to the out: threejs Object, which will be the container.
    # filled objects are created if a fill is provide.
    # outlined objects are created if an outline is provided.
    @newText = (params) ->

        # If the font is not loaded yet,
        # then we put the request in a queue for processing later,
        # once the font has loaded.
        if not EX.style.font
            EX.Visual_Factory.textMeshQueue.push(params)
            return

        # Compute shared variables once.
        if params.fill_color or params.outline_color
            message = params.message

            # 2 is the level of subdivision for the paths that are created.
            shapes  = EX.style.font.generateShapes( message, params.height, 2 )

            geometry = new THREE.ShapeGeometry( shapes )
            geometry.computeBoundingBox()

        if params.fill_color
            EX.Visual_Factory.newFillText(params, shapes, geometry)

        if params.outline_color
            EX.Visual_Factory.newOutlineText(params, shapes, geometry)

        params.out.position.z = + .1


    @newFillText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        textShape = new THREE.BufferGeometry()
        
        color_fill = params.fill_color

        material_fill = new THREE.LineBasicMaterial( {
            color: color_fill,
            side: THREE.DoubleSide
        } )

        # Perform Translations.
        xMid = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )
        #geometry.scale(1, -1, 1)# Flipped y orientation.
        tx = 0
        if params.align_center
            tx = xMid
        geometry.translate( tx, params.height, 0)

        # make shape
        textShape.fromGeometry( geometry )
        text = new THREE.Mesh(textShape, material_fill)
        output.add( text )

    @newOutlineText = (params, shapes, geometry) ->

        output = params.out #new THREE.Object3D()

        color_outline = params.outline_color

        material_outline = new THREE.MeshBasicMaterial( {
            color: color_outline,
            ###
            transparent: true,
            opacity: 1.0,
            FIXME: Specify Opacity settings.
            ###
            side: THREE.DoubleSide
        } )

        # -- Outlines.

        # Make the letters with holes.
        holeShapes = []
        for i in [0...shapes.length] by 1
            shape = shapes[i]
            if shape.holes and shape.holes.length > 0
                for j in [0...shape.holes.length] by 1 #( var j = 0; j < shape.holes.length; j ++ ) {
                    hole = shape.holes[j]
                    holeShapes.push(hole)

        shapes.push.apply( shapes, holeShapes )
        lineText = new THREE.Object3D()
        params.out.position.z = +.1

        
        # translation amount.
        tx = 0
        if params.align_center
            tx = -0.5 * ( geometry.boundingBox.max.x - geometry.boundingBox.min.x )

        #lineText.scale.y = -1
        for i in [0...shapes.length] by 1 #( var i = 0; i < shapes.length; i ++ ) {
            shape = shapes[i]
            lineGeometry = shape.createPointsGeometry()
            #lineGeometry.scale(1, -1, 1)# Flipped y orientation.
            lineGeometry.translate(tx, params.height, 0 )
            lineMesh = new THREE.Line( lineGeometry, material_outline )
            lineText.add( lineMesh )
        
        output.add( lineText )

        return