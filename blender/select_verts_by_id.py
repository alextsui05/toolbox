# Usage:
# Paste this into the Python console in blender.
# Load a mesh and deselect it in Edit mode.
# Go back to Object mode and make sure the mesh is selected.
# Call foo with a list of vertex IDs you want selected, e.g.
#   foo([1, 5, 7])
# Tab into Edit mode and see the vertices highlighted.
def foo(ids):
    for vert in bpy.context.active_object.data.vertices:
        vert.select = False
    for id in ids:
        bpy.context.active_object.data.vertices[id].select = True
