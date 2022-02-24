/*
Name:
    vdf.deo.Textarea
Type:
    Prototype
Extends:
    vdf.core.TextField
Revisions:
    2008/01/17  Initial version in the new 2.0 architecture. (HW, DAE)
*/

/*
@require    vdf/core/TextField.js
*/

/*
Constructor of the checkbox that calls the super constructor (of the TextField) 
and applies to the initializer interface (see vdf.core.init).

@param  eTextarea       Reference to the textarea DOM element.
@param  oParentControl  Reference to the parent control.
*/
vdf.deo.Textarea = function Textarea(eTextarea, oParentControl){
    this.TextField(eTextarea, oParentControl);
};
/*
Implementation of the textarea field (<textarea ..></textarea>).
*/
vdf.definePrototype("vdf.deo.Textarea", "vdf.core.TextField", {

/*
Gives the focus to the field by giving the focus to the textarea element.
*/
focus : function(){
    vdf.sys.dom.focus(this.eElement);
}

});
