###

Story loader class.

Written by Bryce Summers on Mar.27.2018.
Purpose: creates a named set of story generators from the given text file.

###
class BSS.Story_Loader

    constructor: (@place) ->
        @shouldRemoveEOL = false


    # void. Asynchrounously loads stories to the place after text file has loaded.
    load_story: (file_name) ->
        ###
        Read File.
        perform rest of the operations asynchronously when the file loads.
        place will be created then.
        ###
        @readFile(file_name)

    # Reads a file and then creates a story using it.
    readFile: (file_name) ->
        rawFile = new XMLHttpRequest()
        rawFile.open("GET", file_name, true) # True means the request is performed asynchrounously.
        rawFile.storyLoader = @
        rawFile.onreadystatechange = () ->
        
            if rawFile.readyState == 4
                if rawFile.status == 200 || rawFile.status == 0
                    allText = rawFile.responseText
                    @storyLoader.createStories(allText)

        rawFile.send(null)
        return

    ###
       Break lines.
       Break stories.
       Tokenize.
    ###
    # File name --> map: {story name : story_generator, ... start: story_generator }
    # Produces a map of story generator objects that are capable of generating blocks of the story.
    createStories: (text) ->
        console.log(text)

        # Convert all tabs to spaces.
        text = text.replace("\t", " ")

        # Break into lines.
        lines = text.split("\n")

        # Log where the story tokens are.
        block_start_indices = []
        block_end_indices   = []
        for i in [0...lines.length]
            line = lines[i]
            line = line.split(" ")
            line = @filter(line, "")

            # Remove dangerous end of line ghost characters.
            if @shouldRemoveEOL and i < lines.length - 1
                line = @removeEOL(line)

            if line[0] == "story"
                block_start_indices.push(i)
            if line[0] == "the" and line[1] == "end"
                block_end_indices.push(i)

            # Define variable properties.
            if line[0] == "var"
                name = line[1]
                icon_filename = line[2]
                BSS.Operator_Element.mapVariable(name, icon_filename)

            lines[i] = line # Put the line back after tokenization.

        # Try again while removing erroneous extra characters.
        if block_start_indices.length != block_end_indices.length
            @shouldRemoveEOL = true
            @createStories(text)
            return
            throw new Error("Syntax error in start and ends of blocks.")

        # Create Story generators from story blocks.
        map = {}
        start_name = name = lines[0][1]
        for i in [0...block_start_indices.length] by 1
            index_start = block_start_indices[i]
            index_end   = block_end_indices[i]

            block_lines = []
            for index in [index_start..index_end] by 1
                line = lines[index]
                block_lines.push(line)
            storyGenerator = new BSS.Story_Generator(block_lines)

            # Get name from start of block. story NAME
            name = block_lines[0][1]
            map[name] = storyGenerator

            # Handle Starting Story. Once Upon a time.
            if not map.start
                map.start = storyGenerator

        @place.setStoryMap(map)
        return
        

    filter: (array, item) ->
        output = []
        for elem in array
            if elem != item
                output.push(elem)
        return output

    # ["", "", ""] -> last token loses its last character if it is an end of line character.
    removeEOL: (line) ->

        return line if line.length < 1

        # Remove end of line characters that mess things up.
        eol = line[line.length - 1]
        len = eol.length

        return line if len < 2

        last_char = eol[len - 1]

        # Destroy the extra undefined character at the end.
        eol = eol.substring(0, len - 1)
        line[line.length - 1] = eol

        return line