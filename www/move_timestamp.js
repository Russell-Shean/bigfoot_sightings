// Move time stamp
// This script moves the time stamp element out of the text box
// into the navigation bar
// We do it this way because shiny has limited options for changing
// the html of the navigation bar

// reference link: https://www.enablegeek.com/tutorial/javascript-move-element/

//find the timestamp on the page
TimeElem = document.querySelector(".time-stamp");

// find the navigation bar on the page
ButtonsBox = document.querySelector(".nav");

// append the timestamp into the navigation bar
// this also removes the time stamp from it's original location
// ie cut + paste NOT copy + paste
ButtonsBox.appendChild(TimeElem);





// This removes the two giant dumb dots that
// inexplicably appear as part of the navigation bar


//document searches the entire html doc
// querySelector looks for an element using its CSS selector
// remove() removes the element
// we run it twice to remove the two dots to the left

const elem1 = document.querySelector(".nav > li:nth-child(1)");
const elem2 = document.querySelector(".nav > li:nth-child(2)");
const elem7 = document.querySelector(".nav > li:nth-child(7)");


elem7.remove();
elem2.remove();
elem1.remove();

// here's a function that removes a bunch of elements to make everything fit
// in a single screen without scrolling up or down

// define the function that removes everything

function RemoveStuff() {

// Remove the intro text from the first page
document.querySelector("#surveillance-notes-box").remove()


// remove the classifications description box from the second
// page intro
document.querySelector("#classification-descriptions").remove()



// make the map on the first page shorter
document.querySelector("#county_sightings_map").style.height = "360px";

// make the sightings chart on the first page shorter
document.querySelector("#sighting_counts_plot").style.height = "360px";

// remove top margin from the row that contains the
// visuals on page 1
// no longer needed because we removed the intro text
document.querySelector("#dashboard-content-page-one > div:nth-child(1)").style.marginTop = "0px";



// third page


// make sightings point map shorter
document.querySelector("#bigfoots_maps").style.height = "560px";

// find the element with all the point map instructions
let instructions = document.querySelector("#point-map-notes");

// find the element with the point map dropdown menus
let MapDropDowns = document.querySelector(".col-sm-2");

// move instructions into map dropdowns
MapDropDowns.append(instructions);


// remove left margin from the instructions
instructions.style.marginLeft = "0px";

// add padding to instructions
instructions.style.padding = "15px";

// make the background color white
instructions.style.backgroundColor = "white";

// make edges rounded
instructions.style.borderRadius = "15px";

// increase height of the box the map dropdown menus are in
// so that it lines up with map
MapDropDowns.style.height = "560px" ;

// remove the orphaned row that used to contain the instructions
document.querySelector("#choice_selector").remove()


// increase top margin on instructions so they appear anchored to the bottom
instructions.style.marginTop = "40px";




// 4th page
// remove other sources of data section
document.querySelector(".data-definitions-box > div:nth-child(4)").remove()



// remove why are we looking at bigfeets section
document.querySelector(".data-definitions-box > div:nth-child(6)").remove()


// remove can you share code section
document.querySelector(".data-definitions-box > div:nth-child(7)").remove()

// remove extra line breaks
document.querySelector(".data-definitions-box > br:nth-child(5)").remove()

// run twice to remove both
document.querySelector(".data-definitions-box > br:nth-child(5)").remove()


// remove extra sighting conditions
document.querySelector(".data-definitions-box > div:nth-child(2) > ul:nth-child(3) > li:nth-child(3)").remove()


// Remove the parent element for the footer from all pages
//document.querySelector("div.container-fluid:nth-child(5) > div:nth-child(2)").remove()


}



