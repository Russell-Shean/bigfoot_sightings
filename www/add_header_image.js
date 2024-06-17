// Script to append image into header

// create a variable named header that corresponds
// to the navbar's container's html element id
var header = $('.navbar > .container-fluid');

//Append an html container containing an image onto the header
//the html container specifies the image's CSS inline
header.append('<div style=\"float:right\"><a href=\"https://www.bfro.net/\"><img src=\"https://previews.123rf.com/images/andyadi/andyadi2002/andyadi200200100/141050476-black-hairy-cute-bigfoot-vector-logo-design-template.jpg\" alt=\"alt\" style=\"float:right;height: 55px; padding-top:0px;\"> </a></div>');

//log the changes made to the header
console.log(header)


// Source for this code snippet: https://stackoverflow.com/a/50991648