# DitheredCrossfadeNatureShaders
A set of replacement shaders for Unity's Nature/Tree Creator shaders that supports dithered crossfade in LOD Groups.

This project makes use of Unity built-in shader source, see license.txt for copyright and licensing details.

### Notes

The Tree Creator Bark and Tree Creator Leaves shaders (as well as the Fast variant) are not intended to be used directly, they are intended to be used with the Tree Creator, as it generates materials using the Optimized versions of these shaders. Nevertheless I still added support for dithered crossfade to these base shaders.

### Example Usage

1. Create a new material with the `Nature/Tree Creator Bark Crossfade` shader.
2. Create another material with the `Nature/Tree Creator Leaves Crossfade` shader.
3. Create a new tree, and assign the bark material to the branches, and the leaves material to the leaves.
4. Create a new GameObject and give it a LOD Group component.
5. Add the tree GameObject as a child to the LOD GameObject.
6. Set the LOD Group's Fade Mode to Crossfade.
7. Set the LOD Group's Object Size to (roughly) the same as the height of the tree.
8. Remove LOD1 and LOD2 from the LOD Group.
9. Select LOD0 and add a new renderer to the Renderers list, and then assign the tree GameObject to this.
10. Set LOD0's Transition to something appropriate, (e.g. 50).
11. Set LOD0's Fade Transition Width to something appropriate, (e.g. 0.5).

The tree will now fade in and out as the camera moves closer or further away from it.
