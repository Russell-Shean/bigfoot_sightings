# bigfoot_downloader.py

'''

This script scrapes the bigfoot field researchers organization's website (https://www.bfro.net/GDB/) for reports of bigfoot sightings.



'''

# Import libraries ---------------------------------------------------------------------------------------------------

import requests, bs4, re, json, time, secrets


# Define constants --------------------------------------------------------------------------------------------------------

# this is the url of the main page of the sightings database
# all the reports are sublinks or sub-sublinks off of this page
landing_page = "https://www.bfro.net/GDB/"


# output file
# this is the json file where we'll write the reports to
output_file = "all_sightings.json"

# Define functions ---------------------------------------------------------------------------------------------------------


# function to extract sublink
def sublink_extracter(url, css_selector, url_index):
	'''This function extracts all the links from a page from within a specified css selector '''

	# request the html associated with a page
	res = requests.get(url)

	# create a beautiful soup object by parsing html
	soup = bs4.BeautifulSoup(res.text, "html.parser")

	# find all the <a> links that occur inside a cell with the class of .cs
	# this corresponds to links to each US state/Candadian Province/ country
	# or one a state level page, all the counties


	# or on a county page we change it to look for report and media links
	links = soup.select(css_selector)

	urls = []

	for link in links:
		urls.append(url_index + link.get("href"))

	
	return(urls)


# function to extract data from each report page 
def pull_report(report_url):


	# create an empty dictionary
	report = {}

    # download html for report page
	res = requests.get(report_url)

	# parse html 
	soup = bs4.BeautifulSoup(res.text, "html.parser")


	# add additional fields that aren't contained in a .field class

	# extract numbers from report numbers field
	report["report_no"] = ''.join([c if c.isdigit() else '' for c in soup.select(".reportheader")[0].getText()])

	# extract report classification
	classification = soup.select(".reportclassification")[0].getText()

	#get just the letter
	report_letter = re.compile(" [A-C]").findall(classification)

	#remove extra white space and add to dictionary
	report["classification"] = ''.join(report_letter).strip()


	# not the best strategy, but we'll assume that this field
	# will always be the second field, so we'll hardcode it in
	report["summary"] = soup.select("span.field")[1].getText()


	# find all the elements with a field class inside of a <p> element
	field_elems = soup.select("p .field")

	# extract all the keys and values associated with each field
	for i in range(len(field_elems)):

		text = field_elems[i].parent.getText().split(":")[1:]
		text = "".join(text).strip()

		report[field_elems[i].parent.getText().split(":")[0]] = text




	return(report)





# return all the links from the landing page -----------------------------------------------------------------------------------------
all_links = sublink_extracter(url = landing_page, css_selector = ".cs a", url_index = "https://www.bfro.net")


# print(all_links)

# Sort the links into US, Canada, and international -------------------------------------------------------------------------------


# define regex search terms
us_state_reg = re.compile('state=..$')       
ca_province_reg = re.compile('state=ca-.*$')
int_reg = re.compile('state=int-.*$')

# subset the all links list into three seperate lists
us_state_links = list(filter(us_state_reg.search, all_links))     
ca_province_links = list(filter(ca_province_reg.search, all_links))
int_links = list(filter(int_reg.search, all_links))



# extract a list of all the us county links
us_county_links = []

for state in us_state_links:
	us_county_links.extend(sublink_extracter(url = state, css_selector = ".cs a", url_index = "https://www.bfro.net/GDB/"))

# print(us_county_links)

# combine all the links into one list
all_locations_links = us_county_links + ca_province_links + int_links

# flatten the list
# all_locations_links = list(itertools.chain(*all_locations_links))

# find all the links on each county/province/country
# these correpsond to all the individual reports or news articles

# print(all_locations_links)

all_report_links = []

for link in all_locations_links:
	all_report_links.extend(sublink_extracter(url = link ,  css_selector = ".reportcaption a", url_index = "https://www.bfro.net/GDB/"))


print(all_report_links)
# flatten the list
# all_report_links = list(chain.from_iterable(all_report_links))



# create seperate lists for reports and news articles -------------------------------------------------------------------------------------------

# define regex
report_reg = re.compile("show_report")
media_reg = re.compile("show_article")



just_report_links = list(filter(report_reg.search, all_report_links))
just_media_links = list(filter(media_reg.search, all_report_links))

# write links to file (so we can check later for updates?)
with open("report_links.json", "w") as f:
        json.dump(just_report_links, f)

with open("media_links.json", "w") as f:
        json.dump(just_media_links, f)

# put all the sightings into a dictionary ----------------------------------------------------------------------------------------------------

# create empty dictionary
all_sightings_dict = {}

# loop through all the links and add to the dictionary

for i in range(len(just_report_links)):


	# pause for a random amount of time between 0-2 seconds
	time.sleep(secrets.randbelow(200) / 100)


	# pull all the data from the reports and write to file
	all_sightings_dict.update(pull_report(just_report_links[i]))


# write the dictionary to a json file
with open(output_file, "w") as f: 
    json.dump(all_sightings_dict, f)