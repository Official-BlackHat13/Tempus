//
//  Class:
//      VdfField
//
//  Wrapper for html form elements representing an Database field. With this 
//  wrapper all elements (radio, text, select) have the same interface to talk 
//  to.
//
//  Since:
//      23-08-2007
//  Changed:
//      --
//  Version:
//      0.1
//  Creator:
//      Data Access Europe (Edwin van der Velden)
//


//
//  Constructor: Initializes a new instance of the StringBuilder class
//  and appends the given value if supplied
//
//  Params:
//      sValue  The initial value
//
function JStringBuilder(sValue)
{
    this.strings = new Array();
    this.append(sValue);
}

//
//  Appends the given value to the end of this instance.
//
//  Params:
//      sValue  String to append
//
JStringBuilder.prototype.append = function (sValue)
{
    if (sValue)
    {
        this.strings.push(sValue);
    }
}

// 
//  Clears the string buffer
//
JStringBuilder.prototype.clear = function ()
{
    this.strings.length = 1;
}

//
//  Concatenates the collected strings using the array join method.
//
//  Returns:
//      The complete string
//
JStringBuilder.prototype.toString = function ()
{
    return this.strings.join("");
}