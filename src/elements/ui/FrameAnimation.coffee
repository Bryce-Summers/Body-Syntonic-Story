###

FrameAnimation class.
Written by Bryce Summers on 4.20.2018
(While recovering from flu fatigue.)

Cycles through a set of images at a particular position.

###

class EX.FrameAnimation extends BSS.Element


    constructor: () ->

        super()

        # View encapsulates frame and provides position on screen.
        # FIXME: Determine if we need to worry about pivots.
        view = @getVisual()

        @_total_time = 0
        @_time_elapsed = 0
        @_time_per_frame = 1

        @_frames = []
        @_frame_index = 0

        @_frame_sprite = null

    ###
    Configuration.
    ###

    # Configures all properties at once. {duration:, timePerFrame:, frames:[filename, fname, fname, ...], dim:}
    configure: (config) ->
        @setDuration(config.duration)
        @setTimePerFrame(config.timePerFrame)
        @loadFrames(config.frames, config.dim)
        @restart()

    setDuration: (time) ->
        @_total_time = time
        return

    setTimePerFrame: (time) ->
        @_time_per_frame = time
        return

    # INPUT: A list of file names for sprites. null indicates a blank frame.
    # : the dimensions of said sprites.
    loadFrames: (frame_list, dim) ->

        @_frames = []
        @_frame_index = 0

        # Load a Frame sprite for every frame in the frame list.
        for frame_filename in frame_list

            # Null frames are interpreted to be blanks.
            if frame_filename != null
                frame = EX.Visual_Factory.newSprite(frame_filename, dim)
                @_frames.push(frame)

        return

    restart: () ->
        @_time_elapsed = 0
        @_frame_index = 0
        return

    finish: () ->
        @_time_elapsed = @_total_time

    ###
    User Interface.
    ###

    isDone: () ->
        return @_total_time >= @_time_elapsed

    # An input of time links this class to an input tree system.
    time: (dt) ->
        @_time_elapsed += dt

        # End of duration leads to the a settling on the original frame.
        if @_time_elapsed > @_total_time
            @_time_elapsed = @_total_time
            @_frame_index = 0
            return

        # Update frame index.
        if @_frames.length > 0
            @_frame_index = Math.floor(@_time_elapsed / @_time_per_frame) % @_frames.length

            # remove old, add new.
            if @_frame_sprite != null
                view.remove(@_frame_sprite)

            @_frame_sprite
        return