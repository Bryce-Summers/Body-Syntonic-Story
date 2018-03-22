/*
 * Entry Point to demo.
 * Pipes THREE.js and browser IO to game.
 * Written by Bryce Summers on 11/22/2016
 * Refactored by Bryce on 10.23.2017
 */

var renderer;
var root_scene;
var root_camera;

var input;
var root_AABB;

function init()
{
    // run some Tests.
    new EX.Testing();

    // Initialize all of the global material, mesh constructor's, etc.
    EX.init_style();

    init_camera();

    // Initialize Demo through the scene node.
    root_scene = new BSS.Scene();
    
    // Renderer.
    var params = {
        antialias: true,
    };
    
    init_renderer(params);

    // Set Renderer background clear color.
    renderer.setClearColor( 0xD8C49E );

    // Starts up the input tree.
    init_input();

    new EX.Visual_Factory() // Instantiates static content for future static calls.
    
    // Initialize the initial game state using the test place.
    var place = new BSS.Test_Place(root_scene);
    root_scene.addPlace(place);
    root_scene.activatePlace(place); // Activate the place for camera updates.
    root_scene.setViewToPlace(place);
}

function init_camera()
{
    // Camera.
    //var dim = {x:0, y:0, w:window.innerWidth, h:innerHeight, padding:10};
    // Fixed reolution viewport.
    dim = {x:0, y:0, w:1200, h:800, padding:10};
   
    // I may want to change to a perspective camera if we want to start showing depth information.
    root_camera = new THREE.OrthographicCamera( dim.x - dim.w/2, dim.x + dim.w/2, dim.y - dim.h/2, dim.y + dim.h/2, 1, 1000 );
    root_camera.position.z = 4;

    var x = dim.x + dim.w/2;
    var y = dim.y + dim.h/2;
    root_camera.position.x = x;
    root_camera.position.y = y;

    root_camera.lookAt(new THREE.Vector3(x, y, 0))
}

function init_renderer(params)
{
    var container = document.getElementById( 'container' );
    renderer = new THREE.WebGLRenderer(params);
    renderer.setPixelRatio( dim.w / dim.h /*window.devicePixelRatio*/ );
    container.appendChild( renderer.domElement );
    // Set the render based on the size of the window.
    onWindowResize();
}

function init_input()
{
    // Initialize the root of the input specification tree.
    input = new EX.I_All_Main(root_scene, root_camera);

    // Provide the scene with a hook into the io tree.
    root_scene.setInputRoot(input);

    window.addEventListener( 'resize', onWindowResize, false);

    //window.addEventListener("keypress", onKeyPress);
    window.addEventListener("keydown", onKeyPress);

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mousedown", onMouseDown);
    window.addEventListener("mouseup",   onMouseUp);

    // The current system time, used to correctly pass time deltas.
    TIMESTAMP = performance.now();

    // Initialize Time input.
    beginTime();

    TIME_ON = true;
}

function beginTime()
{
    TIMESTAMP = performance.now();
    TIME_ON   = true;
    timestep();
}

function timestep()
{
    if(TIME_ON)
    {
        requestAnimationFrame(timestep)
    }
    else
    {
        return;
    }

    time_new = performance.now()
    var dt = time_new - TIMESTAMP
    TIMESTAMP = time_new

    try
    {
        input.time(dt)
    }
    catch(err)
    { // Stop time on error.
        TIME_ON = false
        throw err
    }

}

// Events.
function onWindowResize( event )
{
    //renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setSize( dim.w, dim.h );
}

// FIXME: ReWire these input events.
function onKeyPress( event )
{
    // Key codes for event.which.
    var LEFT  = 37
    var RIGHT = 39
}

function onMouseMove( event )
{
    input.mouse_move(translateEvent(event));
}

function onMouseDown( e )//event
{
    //http://stackoverflow.com/questions/2405771/is-right-click-a-javascript-event
    var isRightMB;
    e = e || window.event;

    if ("which" in e)  // Gecko (Firefox), WebKit (Safari/Chrome) & Opera
        isRightMB = e.which == 3; 
    else if ("button" in e)  // IE, Opera 
        isRightMB = e.button == 2; 

    if(isRightMB)
        return

    input.mouse_down(translateEvent(e));
}

function onMouseUp( event )
{
    input.mouse_up(translateEvent(event));
}

function animate()
{
    requestAnimationFrame( animate );
    render();
}

function render()
{
    renderer.render(root_scene.getVisualRepresentation(), root_camera);
}

// Since we are using a fixed size screen, we will need to translate the events.
function translateEvent(event)
{
    return {x: event.x -= window.innerWidth/2 - dim.w/2,
            y: event.y/* -= window.innerHeight/2 - dim.h/2*/}
}

init();
animate();