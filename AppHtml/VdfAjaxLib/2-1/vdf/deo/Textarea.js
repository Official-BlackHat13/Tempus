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
This class implements the textarea field which is a multi line text box. No 
special functionality is added to the super class vdf.core.Field. The 
initialization system will automatically recognizes <textarea elements and will 
create an instance of this class for each occurrence.

@code
<textarea name="customer__comments"></textarea>
@code

*/
vdf.definePrototype("vdf.deo.Textarea", "vdf.core.TextField", {

/*
Gives the focus to the field by giving the focus to the textarea element.
*/
focus : function(){
    vdf.sys.dom.focus(this.eElement);
}

});
