#
# Conditional Element
# Written by Bryce Summers on Mar.28.2018
#
# List of Topology mutations from Large sheet.
#
# - Merge
# - Branch
# - Intersect
# - Split
# - Transfer places
#

class BSS.Condition_Element extends BSS.Element

    constructor: () ->
        super(new BSS.Condition_Model())

        @buildFromConfiguration()

    # Instantiate visual.
    buildFromConfiguration: () ->