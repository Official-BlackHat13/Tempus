/*
Name:
    vdf.deo.Hidden
Type:
    Prototype
Extends:
    vdf.core.Field
Revisions:
    2008/01/17  Initial version in the new 2.0 architecture. (HW, DAE)
*/

/*
@require    vdf/core/Field.js
*/

/*
Constructor of that calls the super constructor (of the Field) and applies to 
the initializer interface (see vdf.core.init).

@param  eHidden         Reference to the DOM element.
@param  oParentControl  Reference to the parent control.
*/
vdf.deo.Hidden = function Hidden(eHidden, oParentControl){
    this.Field(eHidden, oParentControl);
};
/*
Implementation of the hidden field.
*/
vdf.definePrototype("vdf.deo.Hidden", "vdf.core.Field", {

/*
@private
*/
bFocusable : false,

/*
Overrides the focus method because a hidden field can't have the focus.
*/
focus : function(){

},

/*
@private
*/
displayLock : function(){

},

/*
@private
*/
displayUnlock : function(){

}

});
